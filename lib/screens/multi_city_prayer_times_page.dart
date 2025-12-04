import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import '../navigation/bottom_nav_bar.dart';
import '../services/geocoding_service.dart';
import '../services/location_service.dart';
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
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingCurrent = false;
  bool _isSearching = false;
  String? _error;

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
    _loadCurrentLocationPrayerTimes();
  }

  @override
  void dispose() {
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

      if (position == null) {
        _showErrorMessage('Konum alınamadı. Lütfen manuel olarak şehir seçin.');
        return;
      }

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final place = placemarks.isNotEmpty ? placemarks.first : null;
      final cityName = place?.locality?.isNotEmpty == true
          ? place!.locality!
          : place?.administrativeArea?.isNotEmpty == true
          ? place!.administrativeArea!
          : 'Mevcut Konum';
      final countryName = place?.country?.isNotEmpty == true ? place!.country! : '';

      final times = await _prayerTimesRepository.getPrayerTimesForLocation(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _cities
          ..clear()
          ..add(CityPrayerTimes(
            cityName: cityName,
            countryName: countryName,
            times: times,
            isCurrentLocation: true,
          ));
      });
    } catch (e) {
      setState(() => _error = 'Konum yüklenemedi: $e');
    } finally {
      setState(() => _isLoadingCurrent = false);
    }
  }

  Future<void> _addCityByName(String cityName) async {
    final query = cityName.trim();
    if (query.isEmpty) return;

    // Duplicate kontrolü
    final alreadyExists = _cities.any((c) => c.cityName.toLowerCase() == query.toLowerCase());
    if (alreadyExists) {
      _showErrorMessage('$query zaten listede');
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final resolved = await _cityResolver.resolveCityByName(query);
      if (resolved == null) {
        _showErrorMessage('Bu şehir bulunamadı, lütfen başka bir şehir deneyin.');
        return;
      }

      final times = await _prayerTimesRepository.getPrayerTimesForCity(
        resolved.cityName,
        resolved.countryName,
      );

      if (!mounted) return;
      setState(() {
        _cities.add(CityPrayerTimes(
          cityName: resolved.cityName,
          countryName: resolved.countryName,
          times: times,
        ));
        _searchController.clear();
      });
    } catch (e) {
      _showErrorMessage('Şehir aranırken bir hata oluştu: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isSearching = false);
    }
  }

  void _removeCity(CityPrayerTimes city) {
    if (city.isCurrentLocation) return;
    setState(() {
      _cities.remove(city);
    });
  }

  Drawer _buildAppDrawer(BuildContext context) {
    final navItems = [
      _NavDestination(
        icon: Icons.location_city,
        label: 'Çoklu Şehir',
        route: '/home',
      ),
      _NavDestination(icon: Icons.calendar_month, label: 'Takvim', route: '/calendar'),
      _NavDestination(icon: Icons.view_week, label: 'Haftalık Vakitler', route: '/weekly_view'),
      _NavDestination(icon: Icons.explore, label: 'Kıble Pusulası', route: '/qibla'),
      _NavDestination(icon: Icons.notifications, label: 'Bildirimler', route: '/notifications'),
      _NavDestination(icon: Icons.accessibility, label: 'Zikirmatik', route: '/zikirmatik'),
      _NavDestination(icon: Icons.settings, label: 'Ayarlar', route: '/settings'),
      _NavDestination(icon: Icons.volunteer_activism, label: 'Destek Ol', route: '/donate'),
    ];

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF4A6375)),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Ezan Hatırlatıcı',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          for (final item in navItems)
            _NavigationTile(
              destination: item,
              onTap: () {
                Navigator.pop(context);
                if (ModalRoute.of(context)?.settings.name == item.route) return;
                Navigator.pushNamed(context, item.route);
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
        title: const Text('Ezan Hatırlatıcı'),
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
                    decoration: const InputDecoration(
                      hintText: 'Şehir ara (örn. Tokyo)',
                      border: OutlineInputBorder(),
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
                        '${city.cityName}, ${city.countryName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (city.isCurrentLocation)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Chip(
                            label: Text('Şu anki konum'),
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
            _PrayerRow(label: 'Sabah', time: formatter.format(times.sabah)),
            _PrayerRow(label: 'Öğle', time: formatter.format(times.ogle)),
            _PrayerRow(label: 'İkindi', time: formatter.format(times.ikindi)),
            _PrayerRow(label: 'Akşam', time: formatter.format(times.aksam)),
            _PrayerRow(label: 'Yatsı', time: formatter.format(times.yatsi)),
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