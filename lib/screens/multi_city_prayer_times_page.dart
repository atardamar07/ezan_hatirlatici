import 'dart:async';
import 'dart:convert';

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
import '../widgets/prayer_times_list.dart';

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
  bool _showSearch = false; // şehir arama yalnızca "+" ile açılır; ana sayfada öz önde
  Timer? _ticker;
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
    // "Sıradaki vakte kalan süre" dakikada bir güncellensin
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  static const _cacheKey = 'homeCache';

  /// Son konumun bugünkü vakitleri: açılışta GPS ve internet beklenmeden anında gösterilir
  Future<CityPrayerTimes?> _readCache() async {
    final raw = (await SharedPreferences.getInstance()).getString(_cacheKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (json['date'] != DateFormat('yyyy-MM-dd').format(DateTime.now())) return null;
      final t = [for (final s in json['times'] as List) DateTime.parse(s as String)];
      return CityPrayerTimes(
        cityName: json['city'] as String,
        countryName: json['country'] as String,
        isCurrentLocation: true,
        times: PrayerTimes(imsak: t[0], gunes: t[1], ogle: t[2], ikindi: t[3], aksam: t[4], yatsi: t[5]),
      );
    } catch (e) {
      debugPrint('Home cache unreadable: $e');
      return null;
    }
  }

  Future<void> _saveCache(CityPrayerTimes city) async {
    final t = city.times;
    await (await SharedPreferences.getInstance()).setString(
      _cacheKey,
      jsonEncode({
        'date': DateFormat('yyyy-MM-dd').format(t.ogle),
        'city': city.cityName,
        'country': city.countryName,
        'times': [
          for (final d in [t.imsak, t.gunes, t.ogle, t.ikindi, t.aksam, t.yatsi]) d.toIso8601String(),
        ],
      }),
    );
  }

  Future<void> _loadCurrentLocationPrayerTimes() async {
    setState(() {
      _isLoadingCurrent = true;
      _error = null;
    });

    if (!_cities.any((c) => c.isCurrentLocation)) {
      final cached = await _readCache();
      if (cached != null && mounted) setState(() => _cities.insert(0, cached));
    }

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

      unawaited(_saveCache(current));
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
        _showSearch = false;
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
    final scheme = Theme.of(context).colorScheme;
    // Vakitler, kıble ve takvim alt sekmelerde; menüde yalnızca ekstralar kalır
    final navItems = [
      _NavDestination(icon: Icons.notifications_outlined, label: loc.notificationsTitle, route: '/notifications'),
      _NavDestination(icon: Icons.touch_app_outlined, label: loc.dhikrCounter, route: '/zikirmatik'),
      _NavDestination(icon: Icons.settings_outlined, label: loc.settings, route: '/settings'),
      _NavDestination(icon: Icons.workspace_premium_outlined, label: loc.adFreeTitle, route: '/donate'),
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [scheme.primary, scheme.tertiary]),
            ),
            child: Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Text(
                loc.appTitle,
                style: TextStyle(color: scheme.onPrimary, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          for (final item in navItems)
            _NavigationTile(
              destination: item,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, item.route).then((_) async {
                  if (!mounted) return;
                  // Ayarlarda hesaplama yöntemi değişmiş olabilir
                  if (item.route == '/settings') _loadCurrentLocationPrayerTimes();
                  // AdMob politikası: geçiş reklamı yalnızca doğal geçiş anında (bir ekrandan
                  // dönüşte), sıklık sınırıyla; reklamsız ekranından dönen kullanıcıya gösterilmez
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
    final theme = Theme.of(context);
    // Ne konum ne şehir varsa arama kendiliğinden açık (konum izni vermeyenler için)
    final searchVisible = _showSearch || (_cities.isEmpty && !_isLoadingCurrent);

    return Scaffold(
      drawer: _buildAppDrawer(context),
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.add_location_alt_outlined),
            tooltip: loc.selectCity,
            onPressed: () {
              if (_showSearch) _searchController.clear();
              setState(() => _showSearch = !_showSearch);
            },
          ),
          // Konum alınamadığında kart hiç oluşmuyor; yenileme bu yüzden kartta değil burada
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: loc.refresh,
            onPressed: _isLoadingCurrent ? null : _loadCurrentLocationPrayerTimes,
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNavBar(currentTab: NavigationTab.home),
      body: Column(
        children: [
          // İnce çubuk: önbellekteki vakitler görünürken arkada yenileniyor
          if (_isLoadingCurrent) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (searchVisible) ...[
                  TextField(
                    controller: _searchController,
                    autofocus: _showSearch,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _addCityByName,
                    decoration: InputDecoration(
                      hintText: loc.searchCity,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 6, 4, 0),
                    child: Text(loc.searchLanguageInfo, style: theme.textTheme.bodySmall),
                  ),
                  _buildSearchSuggestions(),
                  const SizedBox(height: 12),
                ],
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                  ),
                for (final city in _cities)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: city.isCurrentLocation
                        ? _CurrentLocationCard(city: city)
                        : _PrayerCard(city: city, onRemove: () => _removeCity(city)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    if (_searchController.text.trim().isEmpty) return const SizedBox.shrink();

    if (_isLoadingSuggestions) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      );
    }

    if (_suggestions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          for (final suggestion in _suggestions)
            Card(
              margin: const EdgeInsets.only(bottom: 6),
              child: ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: Text(suggestion.cityName),
                subtitle: suggestion.countryName.isEmpty ? null : Text(suggestion.countryName),
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

String _placeName(CityPrayerTimes city) =>
    [city.cityName, city.countryName].where((s) => s.isNotEmpty).join(', ');

/// Ekrandaki beş vakit (ad, saat); Sabah = güneş - 1 saat
List<(String, DateTime)> _fivePrayers(AppLocalizations loc, PrayerTimes t) => [
      (loc.sabah, t.sabah),
      (loc.dhuhr, t.ogle),
      (loc.asr, t.ikindi),
      (loc.maghrib, t.aksam),
      (loc.isha, t.yatsi),
    ];

/// Mevcut konum: sıradaki vakit ve kalan süre büyük kartta, altında günün vakitleri
class _CurrentLocationCard extends StatelessWidget {
  const _CurrentLocationCard({required this.city});

  final CityPrayerTimes city;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onHero = scheme.onPrimary;
    final fmt = DateFormat('HH:mm');
    final prayers = _fivePrayers(loc, city.times);

    final now = DateTime.now();
    final next = prayers.indexWhere((p) => p.$2.isAfter(now));
    // Hepsi geçtiyse sıradaki yarının sabahı (bugünkü saatle yaklaşık)
    final (nextName, nextTime) =
        next == -1 ? (prayers.first.$1, prayers.first.$2.add(const Duration(days: 1))) : prayers[next];
    final left = nextTime.difference(now);
    final heroStyle = theme.textTheme.headlineMedium?.copyWith(color: onHero, fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: [scheme.primary, scheme.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, size: 18, color: onHero),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _placeName(city),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(color: onHero),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                loc.nextPrayerSimple,
                style: theme.textTheme.bodyMedium?.copyWith(color: onHero.withValues(alpha: 0.8)),
              ),
              Row(
                children: [
                  Expanded(child: Text(nextName, style: heroStyle)),
                  Text(fmt.format(nextTime), style: heroStyle),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                loc.timeRemainingHours(left.inHours, left.inMinutes % 60),
                style: theme.textTheme.bodyLarge?.copyWith(color: onHero),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: PrayerTimesList(
              rows: [for (final p in prayers) (p.$1, fmt.format(p.$2))],
              highlight: next == -1 ? null : next,
            ),
          ),
        ),
      ],
    );
  }
}

/// Eklenen diğer şehirler (o şehrin yerel saatiyle; cihaz saatine göre vurgu yapılmaz)
class _PrayerCard extends StatelessWidget {
  const _PrayerCard({required this.city, required this.onRemove});

  final CityPrayerTimes city;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final fmt = DateFormat('HH:mm');

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 12),
                    child: Text(_placeName(city), style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                  onPressed: onRemove,
                ),
              ],
            ),
            PrayerTimesList(
              rows: [for (final p in _fivePrayers(loc, city.times)) (p.$1, fmt.format(p.$2))],
            ),
          ],
        ),
      ),
    );
  }
}
