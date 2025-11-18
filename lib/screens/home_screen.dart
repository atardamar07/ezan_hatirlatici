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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String translatePrayerName(BuildContext context, String name) {
    final loc = AppLocalizations.of(context)!;

    switch (name) {
      case "Fajr":
        return loc.fajr;    // İmsak
      case "Dhuhr":
        return loc.dhuhr;   // Öğle
      case "Asr":
        return loc.asr;     // İkindi
      case "Maghrib":
        return loc.maghrib; // Akşam
      case "Isha":
        return loc.isha;    // Yatsı
      case "Tomorrow Fajr":
        return "${loc.tomorrow} ${loc.fajr}";
    }

    return name;
  }
  Map<String, dynamic>? _todayTimes;
  Map<String, dynamic>? _tomorrowTimes;

  bool _isLoading = true;
  String _currentLocation = '';
  int _selectedMethod = PrayerTimesApi.diyanetMethodId;

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

    _currentLocation =
        _prefs!.getString('currentLocation') ??
            AppLocalizations.of(context)!.selectLocation;

    _selectedMethod =
        _prefs!.getInt('calculationMethod') ?? PrayerTimesApi.diyanetMethodId;

    if (!kIsWeb) {
      await _adService.initialize();
      await NotificationService.initialize();
    }

    await _loadSavedLocation();
  }

  Future<void> _loadSavedLocation() async {
    setState(() => _isLoading = true);

    final locationType = _prefs!.getString('locationType');

    if (locationType != null) {
      _currentLocation = _prefs!.getString('currentLocation') ?? "";
      await _fetchPrayerTimes();
    } else {
      await _getCurrentLocationAndFetchTimes();
    }
  }

  Future<void> _getCurrentLocationAndFetchTimes() async {
    final position = await _locationService.getCurrentLocation();

    if (position != null && mounted) {
      final fullAddress = await _locationService.getFullAddress(
        position.latitude!,
        position.longitude!,
      );

      final locationName = fullAddress?.isNotEmpty == true
          ? fullAddress!
          : "${position.latitude!.toStringAsFixed(2)}, ${position.longitude!.toStringAsFixed(2)}";

      await _prefs!.setString('locationType', 'location');
      await _prefs!.setDouble('latitude', position.latitude!);
      await _prefs!.setDouble('longitude', position.longitude!);
      await _prefs!.setString('currentLocation', locationName);

      setState(() => _currentLocation = locationName);

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
      Map<String, dynamic>? today;
      Map<String, dynamic>? tomorrow;

      final type = _prefs!.getString('locationType');

      if (type == 'location') {
        final lat = _prefs!.getDouble('latitude');
        final lng = _prefs!.getDouble('longitude');

        if (lat != null && lng != null) {
          today = await _prayerApi.getPrayerTimesByLocation(
            lat,
            lng,
            _selectedMethod,
          );

          tomorrow = await _prayerApi.getTomorrowsPrayerTimes(
            lat,
            lng,
            _selectedMethod,
          );
        }
      } else if (type == 'city') {
        final city = _prefs!.getString('selectedCity');
        final country = _prefs!.getString('selectedCountry');

        if (city != null && country != null) {
          today = await _prayerApi.getPrayerTimesByCity(
            city,
            country,
            _selectedMethod,
          );

          tomorrow = null;
        }
      }

      if (today != null) {
        setState(() {
          _todayTimes = today;
          _tomorrowTimes = tomorrow;
        });
      } else {
        throw Exception("Prayer data is null");
      }

      if (!kIsWeb) {
        await NotificationScheduler().scheduleAllPrayerNotifications();
      }
    } catch (e) {
      debugPrint("Prayer fetch error: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.prayerTimesLoadError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CitySelectionScreen()),
    );

    if (result != null && mounted) {
      if (result['type'] == 'location') {
        final fullAddress =
        await _locationService.getFullAddress(result['latitude'], result['longitude']);

        final name = fullAddress ?? result['address'];

        await _prefs!.setString('locationType', 'location');
        await _prefs!.setDouble('latitude', result['latitude']);
        await _prefs!.setDouble('longitude', result['longitude']);
        await _prefs!.setString('currentLocation', name);

        setState(() => _currentLocation = name);
      } else if (result['type'] == 'city') {
        final locationName = "${result['city']}, ${result['country']}";

        await _prefs!.setString('locationType', 'city');
        await _prefs!.setString('selectedCity', result['city']);
        await _prefs!.setString('selectedCountry', result['country']);
        await _prefs!.setString('currentLocation', locationName);

        setState(() => _currentLocation = locationName);
      }

      await _fetchPrayerTimes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer =
    _todayTimes != null ? _prayerApi.getNextPrayer(_todayTimes!) : null;

    final filteredTodayTimes = _todayTimes == null
        ? {}
        : {
      "Fajr": _todayTimes!["Fajr"],
      "Dhuhr": _todayTimes!["Dhuhr"],
      "Asr": _todayTimes!["Asr"],
      "Maghrib": _todayTimes!["Maghrib"],
      "Isha": _todayTimes!["Isha"],
    };

    final tomorrowFajr = _tomorrowTimes?["Fajr"];

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C27),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C27),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: const TextStyle(color: Colors.white),
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
            _buildDrawerItem(Icons.explore, AppLocalizations.of(context)!.qiblaCompass,
                    () => Navigator.pushNamed(context, '/qibla')),
            _buildDrawerItem(Icons.countertops,
                AppLocalizations.of(context)!.dhikrCounter,
                    () => Navigator.pushNamed(context, '/zikirmatik')),
            _buildDrawerItem(Icons.payment, AppLocalizations.of(context)!.donate,
                    () => Navigator.pushNamed(context, '/donate')),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.amber),
        )
            : ListView(
          children: [
            // ⭐ KONUM GÖSTERİMİ (İMSAK ÜSTÜNE)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on,
                      color: Colors.teal, size: 22),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _currentLocation,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
            ),

            // ⭐ BUGÜNÜN 5 VAKTİ
            ...filteredTodayTimes.entries.map((entry) {
              final isNext = entry.key == nextPrayer;
              return Column(
                children: [
                  PrayerCard(
                    prayerName: translatePrayerName(context, entry.key),
                    time: entry.value,
                    isNextPrayer: isNext,
                  ),
                  const SizedBox(height: 6),
                ],
              );
            }),

            // ⭐ YARIN IMSAK
            if (tomorrowFajr != null) ...[
              const SizedBox(height: 12),
              PrayerCard(
                prayerName: translatePrayerName(context, "Tomorrow Fajr"),
                time: tomorrowFajr,
                isNextPrayer: false,
              ),
            ],

            if (!kIsWeb) _adService.buildBannerAd(),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
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
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
