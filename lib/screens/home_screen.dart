import 'dart:async';

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
import 'notification_status_screen.dart';
import 'qibla_screen.dart';
import 'weekly_view_screen.dart';
import '../navigation/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onOpenSettings;

  const HomeScreen({super.key, this.onOpenSettings});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _adTimer;
  Map<String, String> _filteredTodayTimes = {};
  String? _nextPrayer;

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

    }

    return name;
  }
  Map<String, dynamic>? _todayTimes;

  bool _isLoading = true;
  String _currentLocation = '';
  int _selectedMethod = PrayerTimesApi.diyanetMethodId;
  bool _notificationsReady = false;
  bool _locationPermissionGranted = false;
  String _statusMessage = '';

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
      try {
        await _adService.initialize();
      } catch (e, stack) {
        debugPrint('Failed to initialize AdService: $e\n$stack');
        // Continue without ads if initialization fails
      }
      
      try {
        final status = await NotificationService.getStatus();
        if (mounted) {
          setState(() => _notificationsReady =
              status.notificationsEnabled && status.exactAlarmsEnabled);
        }
      } catch (e, stack) {
        debugPrint('Failed to get notification status: $e\n$stack');
        // Continue with notifications disabled
      }
      
      _startAdTimer();
    }

    await _loadSavedLocation();
  }

  void _startAdTimer() {
    _adTimer?.cancel();

    _adTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (!mounted) return;

      final shouldShow = await _adService.shouldShowAd();
      if (shouldShow) {
        _adService.showInterstitialAd();
      }
    });
  }

  Future<void> _loadSavedLocation() async {
    setState(() => _isLoading = true);
    final loc = AppLocalizations.of(context)!;

    final locationType = _prefs!.getString('locationType');

    if (locationType != null) {
      _currentLocation = _prefs!.getString('currentLocation') ?? "";
      _locationPermissionGranted = true;
      _statusMessage = loc.savedLocation(_currentLocation);
      await _fetchPrayerTimes();
    } else {
      setState(() {
        _statusMessage = loc.savedLocation(_currentLocation);
      });
      await _getCurrentLocationAndFetchTimes();
    }
  }

  @override
  void dispose() {
    _adTimer?.cancel();
    _adService.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocationAndFetchTimes() async {
    final position = await _locationService.getCurrentLocation();
    final loc = AppLocalizations.of(context)!;

    setState(() => _locationPermissionGranted = position != null);

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
      setState(() => _statusMessage = loc.locationPermissionActive(locationName));

      await _fetchPrayerTimes();
    } else {
      setState(() {
        _isLoading = false;
        _statusMessage = loc.locationPermissionLimited;
      });

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
    final loc = AppLocalizations.of(context)!;

    try {
      Map<String, dynamic>? today;

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

        }
      }

      if (today != null) {
        setState(() {
          _todayTimes = today;
          _updatePrayerDisplayData();
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
            content: Text(loc.prayerTimesLoadError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _updatePrayerDisplayData() {
    if (_todayTimes == null) {
      _filteredTodayTimes = {};
      _nextPrayer = null;
      return;
    }

    _filteredTodayTimes = {
      "Fajr": _todayTimes!["Fajr"],
      "Dhuhr": _todayTimes!["Dhuhr"],
      "Asr": _todayTimes!["Asr"],
      "Maghrib": _todayTimes!["Maghrib"],
      "Isha": _todayTimes!["Isha"],
    };

    _nextPrayer = _prayerApi.getNextPrayer(_todayTimes!);
  }

  Future<void> _selectLocation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CitySelectionScreen()),
    );

    final loc = AppLocalizations.of(context)!;

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
        setState(() => _statusMessage = loc.locationUpdated(name));
      } else if (result['type'] == 'city') {
        final locationName = "${result['city']}, ${result['country']}";

        await _prefs!.setString('locationType', 'city');
        await _prefs!.setString('selectedCity', result['city']);
        await _prefs!.setString('selectedCountry', result['country']);
        await _prefs!.setString('currentLocation', locationName);

        setState(() => _currentLocation = locationName);
        setState(() => _statusMessage = loc.citySelected(locationName));
      }

      await _fetchPrayerTimes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              if (widget.onOpenSettings != null) {
                widget.onOpenSettings!();
              } else {
                _showCalculationMethods();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showCalculationMethods,
          ),
        ],
      ),

      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration:
              BoxDecoration(color: const Color(0xFF1C1C27)),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.menu,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary),
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
            _buildDrawerItem(
                Icons.settings,
                AppLocalizations.of(context)!.settings,
                    () => widget.onOpenSettings?.call()),
          ],
        ),
      ),

      bottomNavigationBar: const MainBottomNavBar(currentTab: NavigationTab.home),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.amber),
        )
            : ListView(
          children: [
            _buildQuickActions(context),
            const SizedBox(height: 12),
            _buildInfoBanner(),
            const SizedBox(height: 12),
            // ⭐ KONUM GÖSTERİMİ (İMSAK ÜSTÜNE)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on,
                      color: Theme.of(context).colorScheme.primary, size: 22),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _currentLocation,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                ],
              ),
            ),

            // ⭐ BUGÜNÜN 5 VAKTİ
            ..._filteredTodayTimes.entries.map((entry) {
              final isNext = entry.key == _nextPrayer;
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
          ],
        ),
      ),
    );
  }
  Widget _buildQuickActions(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionChip(
            label: loc.quickActionToday,
            icon: Icons.calendar_today,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            ),
          ),
          _buildActionChip(
            label: loc.quickActionWeekly,
            icon: Icons.date_range,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WeeklyViewScreen()),
            ),
          ),
          _buildActionChip(
            label: loc.quickActionNotifications,
            icon: Icons.notifications_active,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationStatusScreen()),
            ),
          ),
          _buildActionChip(
            label: loc.qiblaCompass,
            icon: Icons.explore,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QiblaScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF242433),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ActionChip(
        avatar: Icon(icon, size: 18, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF11B2A2),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: onTap,
      ),
    );
  }

  Widget _buildInfoBanner() {
    final loc = AppLocalizations.of(context)!;
    final String message = _statusMessage.isNotEmpty
        ? _statusMessage
        : _locationPermissionGranted
        ? loc.locationPermissionGranted
        : loc.locationPermissionPending;

    final notificationText = _notificationsReady
        ? loc.locationPermissionGranted
        : loc.locationPermissionPending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF242433),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _locationPermissionGranted ? Icons.check_circle : Icons.info_outline,
            color: _locationPermissionGranted ? Colors.tealAccent : Colors.orangeAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  notificationText,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(
      IconData icon,
      String title,
      VoidCallback onTap,
) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return ListTile(
      leading: Icon(icon, color: onSurface),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _showCalculationMethods() {
    final loc = AppLocalizations.of(context)!;
    final methods = _prayerApi.getCalculationMethods(loc);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.calculationMethod),
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
