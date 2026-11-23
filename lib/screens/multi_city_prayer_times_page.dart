import 'dart:async';

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/bottom_nav_bar.dart';
import '../services/ad_service.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
import '../services/notification_scheduler.dart';
import '../services/prayer_times_api.dart';

/// Namaz vakitleri model sınıfı
class PrayerTimes {
  PrayerTimes({
    required this.imsak,
    required this.gunes,
    required this.ogle,
    required this.ikindi,
    required this.aksam,
    required this.yatsi,
  });

  final DateTime imsak;
  final DateTime gunes;
  final DateTime ogle;
  final DateTime ikindi;
  final DateTime aksam;
  final DateTime yatsi;

  // Sabah = güneş - 1 saat
  DateTime get sabah => gunes.subtract(const Duration(hours: 1));
}

/// Şehir ve ülke bilgisini tutan model
class ResolvedCity {
  const ResolvedCity({
    required this.cityName,
    required this.countryName,
    required this.lat,
    required this.lon,
  });

  final String cityName;
  final String countryName;
  final double lat;
  final double lon;
}

/// Kartlarda kullanılan birleşik model
class CityPrayerTimes {
  const CityPrayerTimes({
    required this.cityName,
    required this.countryName,
    required this.times,
    this.isCurrentLocation = false,
  });

  final String cityName;
  final String countryName;
  final PrayerTimes times;
  final bool isCurrentLocation;
}

/// Namaz vakitleri için soyut depo
abstract class PrayerTimesRepository {
  Future<PrayerTimes> getPrayerTimesForLocation(double lat, double lon);

  Future<PrayerTimes> getPrayerTimesForCity(String cityName, String countryName);
}

/// Şehir çözümleyici
abstract class CityResolver {
  Future<ResolvedCity?> resolveCityByName(String cityName);
}

/// Gerçek şehir çözümleyici (geocoding servisini kullanır)
class GeocodingCityResolver implements CityResolver {
  GeocodingCityResolver({GeocodingService? geocodingService})
      : _geocodingService = geocodingService ?? GeocodingService();

  final GeocodingService _geocodingService;

  @override
  Future<ResolvedCity?> resolveCityByName(String cityName) async {
    final results = await _geocodingService.searchCities(cityName);
    if (results.isEmpty) return null;

    final first = results.first;
    final country = (first['country'] as String?)?.trim();
    final name = (first['name'] as String?)?.trim();
    final lat = first['latitude'] as double?;
    final lon = first['longitude'] as double?;

    if (name == null || lat == null || lon == null) return null;

    return ResolvedCity(
      cityName: name,
      countryName: country?.isNotEmpty == true ? country! : '',
      lat: lat,
      lon: lon,
    );
  }
}

/// Aladhan API kullanarak gerçek namaz vakitleri deposu
class ApiPrayerTimesRepository implements PrayerTimesRepository {
  ApiPrayerTimesRepository({PrayerTimesApi? prayerTimesApi})
      : _prayerTimesApi = prayerTimesApi ?? PrayerTimesApi();

  final PrayerTimesApi _prayerTimesApi;

  Future<int> _getMethod() => _prayerTimesApi.getSavedMethodOrDefault();

  @override
  Future<PrayerTimes> getPrayerTimesForLocation(double lat, double lon) async {
    final method = await _getMethod();
    final timings =
    await _prayerTimesApi.getPrayerTimesByLocation(lat, lon, method);

    if (timings == null) {
      throw Exception('Namaz vakitleri alınamadı');
    }

    return _mapTimingsToPrayerTimes(timings);
  }

  @override
  Future<PrayerTimes> getPrayerTimesForCity(
      String cityName,
      String countryName,
      ) async {
    final method = await _getMethod();
    final timings =
    await _prayerTimesApi.getPrayerTimesByCity(cityName, countryName, method);

    if (timings == null) {
      throw Exception('Namaz vakitleri alınamadı');
    }

    return _mapTimingsToPrayerTimes(timings);
  }

  PrayerTimes _mapTimingsToPrayerTimes(Map<String, dynamic> timings) {
    return PrayerTimes(
      imsak: _parseTime(timings['Fajr'] as String?, 'İmsak'),
      gunes: _parseTime(timings['Sunrise'] as String?, 'Güneş'),
      ogle: _parseTime(timings['Dhuhr'] as String?, 'Öğle'),
      ikindi: _parseTime(timings['Asr'] as String?, 'İkindi'),
      aksam: _parseTime(timings['Maghrib'] as String?, 'Akşam'),
      yatsi: _parseTime(timings['Isha'] as String?, 'Yatsı'),
    );
  }

  DateTime _parseTime(String? raw, String label) {
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(raw ?? '');

    if (match == null) {
      throw FormatException('$label saati çözümlenemedi: $raw');
    }

    final today = DateTime.now();
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);

    return DateTime(today.year, today.month, today.day, hour, minute);
  }
}

/// Multi-city namaz vakitleri sayfası
class MultiCityPrayerTimesPage extends StatefulWidget {
  const MultiCityPrayerTimesPage({super.key});

  @override
  State<MultiCityPrayerTimesPage> createState() => _MultiCityPrayerTimesPageState();
}

class _MultiCityPrayerTimesPageState extends State<MultiCityPrayerTimesPage> {
  final List<CityPrayerTimes> _cities = [];
  final PrayerTimesRepository _prayerTimesRepository = ApiPrayerTimesRepository();
  final CityResolver _cityResolver = GeocodingCityResolver();
  final GeocodingService _geocodingService = GeocodingService();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  final Duration _searchDebounceDuration = const Duration(milliseconds: 300);
  Timer? _searchDebounce;
  bool _isLoadingCurrent = false;
  bool _isSearching = false;
  bool _isLoadingSuggestions = false;
  String? _error;
  List<ResolvedCity> _suggestions = const [];

  void _showErrorMessage(String message) {
    if (!mounted) return;
    setState(() => _error = message);
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  void initState() {
    super.initState();
    // Önce vakitler (konum izni), sonra reklam onayı; iki pencere üst üste binmesin
    _loadCurrentLocationPrayerTimes().whenComplete(() => AdService().initialize());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocationPrayerTimes() async {
    setState(() {
      _isLoadingCurrent = true;
      _error = null;
    });

    try {
      final position = await _locationService.getCurrentLocation();
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;

      ResolvedCity? city;
      if (position != null) {
        city = await _cityForPosition(position.latitude, position.longitude, loc.currentLocation);
        await _savePrimaryLocation(city);
      } else {
        // GPS yoksa son kayıtlı konum (önceki GPS ya da elle seçilen şehir) kullanılır
        final prefs = await SharedPreferences.getInstance();
        final lat = prefs.getDouble('latitude');
        final lon = prefs.getDouble('longitude');
        if (lat != null && lon != null) {
          city = ResolvedCity(
            cityName: prefs.getString('currentLocation') ?? loc.currentLocation,
            countryName: '',
            lat: lat,
            lon: lon,
          );
        }
      }

      if (city == null) {
        _showErrorMessage(loc.locationNotDetected);
        return;
      }

      final current = CityPrayerTimes(
        cityName: city.cityName,
        countryName: city.countryName,
        times: await _prayerTimesRepository.getPrayerTimesForLocation(city.lat, city.lon),
        isCurrentLocation: true,
      );

      if (!mounted) return;
      setState(() {
        _cities
          ..removeWhere((c) => c.isCurrentLocation)
          ..insert(0, current);
      });
    } catch (e) {
      debugPrint('Current location prayer times failed: $e');
      if (mounted) setState(() => _error = AppLocalizations.of(context)!.prayerTimesLoadFailed);
    } finally {
      if (mounted) setState(() => _isLoadingCurrent = false);
      // Her açılışta kayıtlı konumla yeniden kurulur; böylece planlı günler hep ileri kayar
      NotificationScheduler().scheduleAllPrayerNotifications();
    }
  }

  Future<ResolvedCity> _cityForPosition(double lat, double lon, String fallbackName) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lon);
      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final cityName = place?.locality?.isNotEmpty == true
          ? place!.locality!
          : place?.administrativeArea?.isNotEmpty == true
          ? place!.administrativeArea!
          : fallbackName;
      return ResolvedCity(cityName: cityName, countryName: place?.country ?? '', lat: lat, lon: lon);
    } catch (e) {
      // Adres servisi çalışmasa da (ağ yok, cihazda Geocoder yok) vakitler gösterilsin
      debugPrint('Reverse geocoding failed: $e');
      return ResolvedCity(cityName: fallbackName, countryName: '', lat: lat, lon: lon);
    }
  }

  /// Bildirimler, takvim ve kıble pusulası bu kayıtlı konumu kullanır
  Future<void> _savePrimaryLocation(ResolvedCity city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locationType', 'location');
    await prefs.setDouble('latitude', city.lat);
    await prefs.setDouble('longitude', city.lon);
    await prefs.setString('currentLocation',
        [city.cityName, city.countryName].where((s) => s.isNotEmpty).join(', '));
  }

  Future<void> _addCityByName(String cityName) async {
    final query = cityName.trim();
    if (query.isEmpty) return;

    setState(() => _error = null);

    ResolvedCity? resolved;
    try {
      resolved = await _cityResolver.resolveCityByName(query);
    } catch (e) {
      // Geocoder sonuç bulamayınca da hata fırlatır
      debugPrint('City search failed: $e');
    }
    if (!mounted) return;

    if (resolved == null) {
      _showErrorMessage(AppLocalizations.of(context)!.cityNotFound);
      return;
    }
    await _addResolvedCity(resolved);
  }

  Future<void> _addResolvedCity(ResolvedCity city) async {
    final alreadyExists =
    _cities.any((c) => c.cityName.toLowerCase() == city.cityName.toLowerCase());
    if (alreadyExists) {
      _searchController.clear();
      return;
    }

    // Konum izni yoksa ilk seçilen şehir ana konum olur (bildirim, takvim, kıble için)
    final isPrimary = !_isLoadingCurrent && !_cities.any((c) => c.isCurrentLocation);

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final times = await _prayerTimesRepository.getPrayerTimesForLocation(
        city.lat,
        city.lon,
      );

      if (isPrimary) {
        await _savePrimaryLocation(city);
        NotificationScheduler().scheduleAllPrayerNotifications();
      }

      if (!mounted) return;
      setState(() {
        _cities.add(CityPrayerTimes(
          cityName: city.cityName,
          countryName: city.countryName,
          times: times,
          isCurrentLocation: isPrimary,
        ));
        _searchController.clear();
        _suggestions = const [];
      });
    } catch (e) {
      debugPrint('Adding city failed: $e');
      if (mounted) _showErrorMessage(AppLocalizations.of(context)!.prayerTimesLoadFailed);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _suggestions = const [];
        _error = null;
      });
      return;
    }

    _searchDebounce = Timer(_searchDebounceDuration, () => _loadSuggestions(query));
  }

  Future<void> _loadSuggestions(String query) async {
    setState(() {
      _isLoadingSuggestions = true;
      _error = null;
    });

    try {
      final results = await _geocodingService.searchCities(query);
      final mappedResults = results.take(3).map((city) {
        final name = (city['name'] as String?)?.trim();
        final country = (city['country'] as String?)?.trim() ?? '';
        final lat = city['latitude'] as double?;
        final lon = city['longitude'] as double?;

        if (name == null || lat == null || lon == null) return null;

        return ResolvedCity(
          cityName: name,
          countryName: country,
          lat: lat,
          lon: lon,
        );
      }).whereType<ResolvedCity>().toList();

      if (!mounted) return;
      setState(() => _suggestions = mappedResults);
    } catch (e) {
      // Yazarken eşleşme olmaması normal; geocoder bunu hata olarak fırlatır, uyarı gösterme
      debugPrint('City suggestions failed: $e');
      if (mounted) setState(() => _suggestions = const []);
    } finally {
      if (mounted) setState(() => _isLoadingSuggestions = false);
    }
  }

  void _removeCity(CityPrayerTimes city) {
    if (city.isCurrentLocation) return;
    setState(() {
      _cities.remove(city);
    });
  }

  Drawer _buildAppDrawer(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final navItems = [
      _NavDestination(icon: Icons.location_city, label: loc.home, route: '/home'),
      _NavDestination(icon: Icons.calendar_month, label: loc.calendarTitle, route: '/calendar'),
      _NavDestination(icon: Icons.explore, label: loc.qiblaCompass, route: '/qibla'),
      _NavDestination(icon: Icons.notifications, label: loc.notificationsTitle, route: '/notifications'),
      _NavDestination(icon: Icons.accessibility, label: loc.dhikrCounter, route: '/zikirmatik'),
      _NavDestination(icon: Icons.settings, label: loc.settings, route: '/settings'),
      _NavDestination(icon: Icons.volunteer_activism, label: loc.donate, route: '/donate'),
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF4A6375)),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                loc.appTitle,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          for (final item in navItems)
            _NavigationTile(
              destination: item,
              onTap: () {
                Navigator.pop(context);
                if (ModalRoute.of(context)?.settings.name == item.route) return;
                Navigator.pushNamed(context, item.route).then((_) async {
                  if (!mounted) return;
                  // Ayarlarda hesaplama yöntemi değişmiş olabilir
                  if (item.route == '/settings') _loadCurrentLocationPrayerTimes();
                  // AdMob politikası: geçiş reklamı yalnızca doğal geçiş anında (bir ekrandan
                  // dönüşte), sıklık sınırıyla; destek ekranından dönen kullanıcıya gösterilmez
                  final ads = AdService();
                  if (item.route != '/donate' && await ads.shouldShowAd()) {
                    ads.showInterstitialAd();
                  }
                });
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      drawer: _buildAppDrawer(context),
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          // Konum alınamadığında kart hiç oluşmuyor; yenileme bu yüzden kartta değil burada
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: loc.refresh,
            onPressed: _isLoadingCurrent ? null : _loadCurrentLocationPrayerTimes,
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNavBar(
        currentTab: NavigationTab.home,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _addCityByName,
                    decoration: InputDecoration(
                      hintText: loc.searchCity,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSearching
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.search),
                  onPressed: _isSearching
                      ? null
                      : () => _addCityByName(_searchController.text),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                loc.searchLanguageInfo,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          _buildSearchSuggestions(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_isLoadingCurrent)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _cities.length,
              itemBuilder: (context, index) {
                final city = _cities[index];
                return _PrayerCard(
                  city: city,
                  onRemove: city.isCurrentLocation ? null : () => _removeCity(city),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    if (_searchController.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    if (_isLoadingSuggestions) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: LinearProgressIndicator(),
      );
    }

    if (_suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          for (final suggestion in _suggestions)
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_searching),
                title: Text(suggestion.cityName),
                subtitle: Text(suggestion.countryName),
                onTap: () => _addResolvedCity(suggestion),
              ),
            ),
        ],
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.icon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final String label;
  final String route;
}

class _NavigationTile extends StatelessWidget {
  const _NavigationTile({required this.destination, required this.onTap});

  final _NavDestination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(destination.icon),
      title: Text(destination.label),
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.city,
    this.onRemove,
  });

  final CityPrayerTimes city;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final formatter = DateFormat('HH:mm');
    final times = city.times;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        [city.cityName, city.countryName].where((s) => s.isNotEmpty).join(', '),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (city.isCurrentLocation)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Chip(
                            label: Text(loc.currentLocation),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            _PrayerRow(label: loc.sabah, time: formatter.format(times.sabah)),
            _PrayerRow(label: loc.dhuhr, time: formatter.format(times.ogle)),
            _PrayerRow(label: loc.asr, time: formatter.format(times.ikindi)),
            _PrayerRow(label: loc.maghrib, time: formatter.format(times.aksam)),
            _PrayerRow(label: loc.isha, time: formatter.format(times.yatsi)),
          ],
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    required this.label,
    required this.time,
  });

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            time,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}