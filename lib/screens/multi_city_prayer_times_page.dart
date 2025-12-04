import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../navigation/bottom_nav_bar.dart';

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

  Future<PrayerTimes> getPrayerTimesForCity(String cityName);
}

/// Şehir çözümleyici
abstract class CityResolver {
  Future<ResolvedCity?> resolveCityByName(String cityName);
}

/// Fake şehir çözümleyici (hazır şehir listesi)
class FakeCityResolver implements CityResolver {
  FakeCityResolver();

  final Map<String, ResolvedCity> _cities = {
    'antalya': const ResolvedCity(
      cityName: 'Antalya',
      countryName: 'Türkiye',
      lat: 36.8969,
      lon: 30.7133,
    ),
    'tokyo': const ResolvedCity(
      cityName: 'Tokyo',
      countryName: 'Japan',
      lat: 35.6764,
      lon: 139.6500,
    ),
    'london': const ResolvedCity(
      cityName: 'London',
      countryName: 'United Kingdom',
      lat: 51.5072,
      lon: -0.1276,
    ),
    'mecca': const ResolvedCity(
      cityName: 'Mecca',
      countryName: 'Saudi Arabia',
      lat: 21.3891,
      lon: 39.8579,
    ),
    'medina': const ResolvedCity(
      cityName: 'Medina',
      countryName: 'Saudi Arabia',
      lat: 24.5247,
      lon: 39.5692,
    ),
  };

  List<ResolvedCity> get availableCities {
    final entries = _cities.values.toList()
      ..sort((a, b) => a.cityName.compareTo(b.cityName));
    return entries;
  }

  @override
  Future<ResolvedCity?> resolveCityByName(String cityName) async {
    final key = cityName.toLowerCase().trim();
    return _cities[key];
  }
}

/// Fake namaz vakitleri deposu
class FakePrayerTimesRepository implements PrayerTimesRepository {
  FakePrayerTimesRepository();

  final Map<String, PrayerTimes> _prayerTimes = {};

  @override
  Future<PrayerTimes> getPrayerTimesForLocation(double lat, double lon) async {
    // Varsayılan olarak Antalya koordinatlarını kullan
    return _prayerTimes['antalya'] ?? _generateDefaultForCity('antalya');
  }

  @override
  Future<PrayerTimes> getPrayerTimesForCity(String cityName) async {
    final key = cityName.toLowerCase().trim();
    return _prayerTimes[key] ?? _generateDefaultForCity(key);
  }

  PrayerTimes _generateDefaultForCity(String key) {
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    // Saatler örnek olması için sabit
    switch (key) {
      case 'tokyo':
        return _prayerTimes[key] = PrayerTimes(
          imsak: base.add(const Duration(hours: 4, minutes: 30)),
          gunes: base.add(const Duration(hours: 5, minutes: 50)),
          ogle: base.add(const Duration(hours: 12, minutes: 10)),
          ikindi: base.add(const Duration(hours: 15, minutes: 45)),
          aksam: base.add(const Duration(hours: 18, minutes: 35)),
          yatsi: base.add(const Duration(hours: 20, minutes: 0)),
        );
      case 'london':
        return _prayerTimes[key] = PrayerTimes(
          imsak: base.add(const Duration(hours: 3, minutes: 40)),
          gunes: base.add(const Duration(hours: 5, minutes: 5)),
          ogle: base.add(const Duration(hours: 12, minutes: 30)),
          ikindi: base.add(const Duration(hours: 16, minutes: 10)),
          aksam: base.add(const Duration(hours: 19, minutes: 55)),
          yatsi: base.add(const Duration(hours: 21, minutes: 20)),
        );
      case 'mecca':
        return _prayerTimes[key] = PrayerTimes(
          imsak: base.add(const Duration(hours: 4, minutes: 20)),
          gunes: base.add(const Duration(hours: 5, minutes: 45)),
          ogle: base.add(const Duration(hours: 12, minutes: 5)),
          ikindi: base.add(const Duration(hours: 15, minutes: 35)),
          aksam: base.add(const Duration(hours: 18, minutes: 25)),
          yatsi: base.add(const Duration(hours: 19, minutes: 50)),
        );
      case 'medina':
        return _prayerTimes[key] = PrayerTimes(
          imsak: base.add(const Duration(hours: 4, minutes: 25)),
          gunes: base.add(const Duration(hours: 5, minutes: 50)),
          ogle: base.add(const Duration(hours: 12, minutes: 0)),
          ikindi: base.add(const Duration(hours: 15, minutes: 30)),
          aksam: base.add(const Duration(hours: 18, minutes: 20)),
          yatsi: base.add(const Duration(hours: 19, minutes: 45)),
        );
      case 'antalya':
      default:
        return _prayerTimes[key] = PrayerTimes(
          imsak: base.add(const Duration(hours: 4, minutes: 15)),
          gunes: base.add(const Duration(hours: 5, minutes: 40)),
          ogle: base.add(const Duration(hours: 12, minutes: 15)),
          ikindi: base.add(const Duration(hours: 15, minutes: 45)),
          aksam: base.add(const Duration(hours: 18, minutes: 55)),
          yatsi: base.add(const Duration(hours: 20, minutes: 20)),
        );
    }
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
  final PrayerTimesRepository _prayerTimesRepository = FakePrayerTimesRepository();
  final FakeCityResolver _cityResolver = FakeCityResolver();
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
      // GPS entegrasyonu yerine Antalya sabit konumunu kullanıyoruz
      const current = ResolvedCity(
        cityName: 'Antalya',
        countryName: 'Türkiye',
        lat: 36.8969,
        lon: 30.7133,
      );

      final times =
        await _prayerTimesRepository.getPrayerTimesForLocation(current.lat, current.lon);

      setState(() {
        _cities
          ..clear()
          ..add(CityPrayerTimes(
            cityName: current.cityName,
            countryName: current.countryName,
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

      final times = await _prayerTimesRepository.getPrayerTimesForCity(resolved.cityName);

      if (!mounted) return;
      setState(() {
        _cities.add(CityPrayerTimes(
          cityName: resolved.cityName,
          countryName: resolved.countryName,
          times: times,
        ));
        _searchController.clear();
      });
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
      _NavDestination(icon: Icons.volunteer_activism, label: 'Bağış Yap', route: '/donate'),
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
                'Hazır şehirlerden seçebilir veya arama kutusuna yazarak ekleyebilirsin.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final city in _cityResolver.availableCities)
                  ActionChip(
                    label: Text(city.cityName),
                    onPressed: _isSearching ? null : () => _addCityByName(city.cityName),
                  ),
              ],
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