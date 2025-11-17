import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/ad_service.dart';
import '../services/location_service.dart';
import '../services/prayer_times_api.dart';
import '../services/notification_scheduler.dart';
import '../services/notification_service.dart';
import '../widgets/prayer_card.dart';
import 'city_selection_screen.dart';
import 'zikirmatik_screen.dart';
import 'qibla_screen.dart';
import 'donation_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _prayerTimes;
  bool _isLoading = true;
  String _currentLocation = '';
  int _selectedMethod = 0;

  final LocationService _locationService = LocationService();
  final PrayerTimesApi _prayerApi = PrayerTimesApi();
  final AdService _adService = AdService();
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _prefs = await SharedPreferences.getInstance();
    _currentLocation = _prefs!.getString('currentLocation') ??
        AppLocalizations.of(context)!.selectLocation;

    if (!kIsWeb) {
      await _adService.initialize();
      await NotificationService.initialize();
    }

    await _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    setState(() => _isLoading = true);

    final savedMethod = _prefs!.getInt('calculationMethod') ?? 0;
    final locationType = _prefs!.getString('locationType');

    if (locationType != null) {
      setState(() {
        _selectedMethod = savedMethod;
        _currentLocation = _prefs!.getString('currentLocation') ?? _currentLocation;
      });
      await _fetchPrayerTimes();
    } else {
      await _getCurrentLocationAndFetchTimes();
    }
  }

  Future<void> _getCurrentLocationAndFetchTimes() async {
    final location = await _locationService.getCurrentLocation();

    if (location != null && mounted) {
      final address = await _locationService.getAddressFromLocation(
          location.latitude!, location.longitude!);

      final locationName = address ??
          "${location.latitude!.toStringAsFixed(2)}, ${location.longitude!.toStringAsFixed(2)}";

      await _prefs!.setString('locationType', 'location');
      await _prefs!.setDouble('latitude', location.latitude!);
      await _prefs!.setDouble('longitude', location.longitude!);
      await _prefs!.setString('currentLocation', locationName);

      setState(() {
        _currentLocation = locationName;
      });

      await _fetchPrayerTimes();
    } else {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.locationNotDetected),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _fetchPrayerTimes() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      Map<String, dynamic>? times;
      final locationType = _prefs!.getString('locationType');

      if (locationType == 'location') {
        final lat = _prefs!.getDouble('latitude');
        final lng = _prefs!.getDouble('longitude');
        if (lat != null && lng != null) {
          times = await _prayerApi.getPrayerTimesByLocation(lat, lng, _selectedMethod);
        }
      } else if (locationType == 'city') {
        final city = _prefs!.getString('selectedCity');
        final country = _prefs!.getString('selectedCountry');
        if (city != null && country != null) {
          times = await _prayerApi.getPrayerTimesByCity(city, country, _selectedMethod);
        }
      }

      if (times != null && mounted) {
        setState(() => _prayerTimes = times);
        // Bildirimleri planla
        if (!kIsWeb) {
          await NotificationScheduler().scheduleAllPrayerNotifications();
        }
      } else {
        throw Exception('Could not load prayer times');
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.prayerTimesLoadError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CitySelectionScreen()),
    );

    if (result != null && mounted) {
      if (result['type'] == 'location') {
        await _prefs!.setString('locationType', 'location');
        await _prefs!.setDouble('latitude', result['latitude']);
        await _prefs!.setDouble('longitude', result['longitude']);
        await _prefs!.setString('currentLocation', result['address']);
        setState(() => _currentLocation = result['address']);
      } else if (result['type'] == 'city') {
        await _prefs!.setString('locationType', 'city');
        await _prefs!.setString('selectedCity', result['city']);
        await _prefs!.setString('selectedCountry', result['country']);
        final locationName = '${result['city']}, ${result['country']}';
        await _prefs!.setString('currentLocation', locationName);
        setState(() => _currentLocation = locationName);
      }

      await _fetchPrayerTimes();
    }
  }

  void _showCalculationMethods() {
    final methods = _prayerApi.getCalculationMethods();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.calculationMethod),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: methods.length,
            itemBuilder: (context, index) {
              final method = methods[index];
              return RadioListTile<int>(
                title: Text(method['name']),
                subtitle: Text(method['description']),
                value: method['id'],
                groupValue: _selectedMethod,
                onChanged: (value) async {
                  if (value != null) {
                    setState(() => _selectedMethod = value);
                    await _prefs!.setInt('calculationMethod', value);
                    Navigator.pop(context);
                    await _fetchPrayerTimes();
                  }
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = _prayerTimes != null
        ? _prayerApi.getNextPrayer(_prayerTimes!)
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C27),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${AppLocalizations.of(context)!.appTitle} - $_currentLocation',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showCalculationMethods,
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFF2C2C38),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1C1C27)),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.menu,
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),
            _buildDrawerItem(Icons.home, AppLocalizations.of(context)!.home, () {}),
            _buildDrawerItem(Icons.explore, AppLocalizations.of(context)!.qiblaCompass, () {
              Navigator.pushNamed(context, '/qibla');
            }),
            _buildDrawerItem(Icons.countertops, AppLocalizations.of(context)!.dhikrCounter, () {
              Navigator.pushNamed(context, '/zikirmatik');
            }),
            _buildDrawerItem(Icons.payment, AppLocalizations.of(context)!.donate, () {
              Navigator.pushNamed(context, '/donate');
            }),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _selectLocation,
              icon: const Icon(Icons.location_on, color: Colors.white),
              label: Text(
                _currentLocation,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (nextPrayer != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade800,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      '${AppLocalizations.of(context)!.nextPrayerSimple}: $nextPrayer',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                  : _prayerTimes == null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mosque, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.prayerTimesLoadFailed,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchPrayerTimes,
                      child: Text(AppLocalizations.of(context)!.retry),
                    ),
                  ],
                ),
              )
                  : ListView(
                children: _prayerTimes!.entries.expand((entry) {
                  final isNext = entry.key == nextPrayer;
                  return [
                    PrayerCard(
                      prayerName: entry.key,
                      time: entry.value,
                      isNextPrayer: isNext,
                    ),
                    const SizedBox(height: 4),
                  ];
                }).toList(),
              ),
            ),
            if (!kIsWeb) _adService.buildBannerAd(),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
}