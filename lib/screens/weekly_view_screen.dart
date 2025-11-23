import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../navigation/bottom_nav_bar.dart';
import '../services/prayer_times_api.dart';
import '../l10n/app_localizations.dart';

class WeeklyViewScreen extends StatefulWidget {
  const WeeklyViewScreen({super.key});

  @override
  State<WeeklyViewScreen> createState() => _WeeklyViewScreenState();
}

class _WeeklyViewScreenState extends State<WeeklyViewScreen> {
  final PrayerTimesApi _prayerApi = PrayerTimesApi();

  bool _isLoading = true;
  String? _statusMessage;
  int _selectedMethod = PrayerTimesApi.diyanetMethodId;

  double? _latitude;
  double? _longitude;
  String? _city;
  String? _country;

  final List<_DailyPrayerTimes> _weeklyTimes = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMethod = await _prayerApi.getSavedMethodOrDefault();

    setState(() => _selectedMethod = savedMethod);
    final loc = AppLocalizations.of(context)!;

    final locationType = prefs.getString('locationType');

    if (locationType == 'location') {
      _latitude = prefs.getDouble('latitude');
      _longitude = prefs.getDouble('longitude');

      if (_latitude == null || _longitude == null) {
        setState(() {
          _statusMessage = loc.locationInfoMissing;
          _isLoading = false;
        });
        return;
      }
    } else if (locationType == 'city') {
      _city = prefs.getString('selectedCity');
      _country = prefs.getString('selectedCountry');

      if (_city == null || _country == null) {
        setState(() {
          _statusMessage = loc.cityInfoMissing;
          _isLoading = false;
        });
        return;
      }
    } else {
      setState(() {
        _statusMessage = loc.selectLocationOrCity;
        _isLoading = false;
      });
      return;
    }

    await _fetchWeeklyTimes();
  }

  Future<void> _fetchWeeklyTimes() async {
    final loc = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _weeklyTimes.clear();
    });

    final today = DateTime.now();
    final futures = List.generate(7, (index) {
      final date = today.add(Duration(days: index));
      return _prayerApi.getPrayerTimesForDate(
        date: date,
        lat: _latitude,
        lng: _longitude,
        city: _city,
        country: _country,
        method: _selectedMethod,
      ).then((timings) => _DailyPrayerTimes(date: date, timings: timings));
    });

    final results = await Future.wait(futures);

    if (!mounted) return;

    setState(() {
      _weeklyTimes.addAll(results);
      _isLoading = false;
      if (_weeklyTimes.every((day) => day.timings == null)) {
        _statusMessage = loc.weeklyTimesUnavailable;
      }
    });
  }

  String _translatePrayerName(String name) {
    final loc = AppLocalizations.of(context);
    switch (name) {
      case "Fajr":
        return loc?.fajr ?? 'Fajr';
      case "Sunrise":
        return loc?.sunrise ?? 'Sunrise';
      case "Dhuhr":
        return loc?.dhuhr ?? 'Dhuhr';
      case "Asr":
        return loc?.asr ?? 'Asr';
      case "Maghrib":
        return loc?.maghrib ?? 'Maghrib';
      case "Isha":
        return loc?.isha ?? 'Isha';
    }

    return name;
  }

  Widget _buildDayCard(_DailyPrayerTimes day) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dateText = DateFormat('EEEE, d MMMM', locale).format(day.date);
    final order = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateText,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            if (day.timings == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(AppLocalizations.of(context)!.dataUnavailable),
              )
            else
              ...order
                  .where((key) => day.timings!.containsKey(key))
                  .map(
                    (key) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: Text(_translatePrayerName(key)),
                  trailing: Text(day.timings![key]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.weeklyViewTitle),
        actions: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.refresh,
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchWeeklyTimes,
          ),
        ],
      ),
      bottomNavigationBar: const MainBottomNavBar(currentTab: NavigationTab.weekly),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _statusMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            Expanded(
              child: _weeklyTimes.isEmpty
                  ? Center(child: Text(AppLocalizations.of(context)!.weeklyDataMissing))
                  : ListView.builder(
                itemCount: _weeklyTimes.length,
                itemBuilder: (context, index) => _buildDayCard(
                  _weeklyTimes[index],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyPrayerTimes {
  final DateTime date;
  final Map<String, dynamic>? timings;

  _DailyPrayerTimes({required this.date, required this.timings});
}