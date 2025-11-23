import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../navigation/bottom_nav_bar.dart';
import '../services/prayer_times_api.dart';
import '../l10n/app_localizations.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final PrayerTimesApi _prayerApi = PrayerTimesApi();
  Map<String, dynamic>? _selectedDayTimings;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _isLoading = true;
  String? _statusMessage;
  int _selectedMethod = PrayerTimesApi.diyanetMethodId;

  double? _latitude;
  double? _longitude;
  String? _city;
  String? _country;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMethod = await _prayerApi.getSavedMethodOrDefault();

    setState(() => _selectedMethod = savedMethod);

    final locationType = prefs.getString('locationType');

    if (locationType == 'location') {
      _latitude = prefs.getDouble('latitude');
      _longitude = prefs.getDouble('longitude');

      if (_latitude == null || _longitude == null) {
        setState(() {
          _statusMessage = 'Konum bilgisi bulunamadı.';
          _isLoading = false;
        });
        return;
      }
    } else if (locationType == 'city') {
      _city = prefs.getString('selectedCity');
      _country = prefs.getString('selectedCountry');

      if (_city == null || _country == null) {
        setState(() {
          _statusMessage = 'Şehir bilgisi bulunamadı.';
          _isLoading = false;
        });
        return;
      }
    } else {
      setState(() {
        _statusMessage = 'Lütfen önce konum veya şehir seçin.';
        _isLoading = false;
      });
      return;
    }

    await _fetchPrayerTimesForDate(_selectedDay);
  }

  Future<void> _fetchPrayerTimesForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final timings = await _prayerApi.getPrayerTimesForDate(
      date: date,
      lat: _latitude,
      lng: _longitude,
      city: _city,
      country: _country,
      method: _selectedMethod,
    );

    if (!mounted) return;

    setState(() {
      _selectedDayTimings = timings;
      _statusMessage = timings == null ? 'Vakitler getirilemedi.' : null;
      _isLoading = false;
    });
  }

  String _translatePrayerName(BuildContext context, String name) {
    final loc = AppLocalizations.of(context);

    switch (name) {
      case "Fajr":
        return loc?.fajr ?? 'İmsak';
      case "Sunrise":
        return loc?.sunrise ?? 'Güneş';
      case "Dhuhr":
        return loc?.dhuhr ?? 'Öğle';
      case "Asr":
        return loc?.asr ?? 'İkindi';
      case "Maghrib":
        return loc?.maghrib ?? 'Akşam';
      case "Isha":
        return loc?.isha ?? 'Yatsı';
    }

    return name;
  }

  List<Widget> _buildPrayerList(BuildContext context) {
    if (_selectedDayTimings == null) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text(
            _statusMessage ?? 'Seçilen güne ait veri bulunamadı.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ];
    }

    const order = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return order
        .where((key) => _selectedDayTimings!.containsKey(key))
        .map(
          (key) => Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Icon(
            Icons.access_time,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(_translatePrayerName(context, key)),
          trailing: Text(_selectedDayTimings![key]),
        ),
      ),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Takvim'),
      ),
      bottomNavigationBar: const MainBottomNavBar(currentTab: NavigationTab.calendar),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<CalendarFormat>(
              segments: const [
                ButtonSegment(
                  value: CalendarFormat.week,
                  icon: Icon(Icons.view_week),
                  label: Text('Haftalık'),
                ),
                ButtonSegment(
                  value: CalendarFormat.month,
                  icon: Icon(Icons.calendar_view_month),
                  label: Text('Aylık'),
                ),
              ],
              selected: {_calendarFormat},
              onSelectionChanged: (selection) {
                setState(() => _calendarFormat = selection.first);
              },
            ),
            const SizedBox(height: 12),
            TableCalendar(
              firstDay: DateTime.utc(2010, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              availableCalendarFormats: const {
                CalendarFormat.month: 'Aylık',
                CalendarFormat.week: 'Haftalık',
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _fetchPrayerTimesForDate(selectedDay);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Seçilen gün vakitleri',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: ListView(
                  children: _buildPrayerList(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}