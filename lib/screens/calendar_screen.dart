import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  Map<DateTime, Map<String, dynamic>> _monthlyTimings = {};

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

    await _fetchMonthlyPrayerTimes(_focusedDay);
  }

  Future<void> _fetchPrayerTimesForDate(DateTime date) async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final loc = AppLocalizations.of(context)!;

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
      _statusMessage = timings == null ? loc.failedToLoadPrayerTimes : null;
      _isLoading = false;
    });
  }

  Future<void> _fetchMonthlyPrayerTimes(DateTime date) async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
      _monthlyTimings = {};
    });

    final loc = AppLocalizations.of(context)!;

    final monthData = await _prayerApi.getMonthlyPrayerTimes(
      month: date.month,
      year: date.year,
      lat: _latitude,
      lng: _longitude,
      city: _city,
      country: _country,
      method: _selectedMethod,
    );

    if (!mounted) return;

    if (monthData == null || monthData.isEmpty) {
      setState(() {
        _selectedDayTimings = null;
        _statusMessage = loc.failedToLoadPrayerTimes;
        _isLoading = false;
      });
      return;
    }

    final normalizedSelected = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    setState(() {
      _monthlyTimings = monthData;
      _selectedDayTimings = _monthlyTimings[normalizedSelected];
      _statusMessage = null;
      _isLoading = false;
    });

    if (_selectedDayTimings == null) {
      await _fetchPrayerTimesForDate(_selectedDay);
    }
  }

  String _translatePrayerName(BuildContext context, String name) {
    final loc = AppLocalizations.of(context);

    switch (name) {
      case "Sabah":
        return loc?.sabah ?? 'Sabah';
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

  Map<String, String> _formatDisplayTimings(
      Map<String, dynamic> timings, DateTime date) {
    final sabahTime = _calculateSabahTime(timings, date);

    return {
      "Sabah": sabahTime ?? timings["Fajr"] ?? "",
      "Dhuhr": timings["Dhuhr"] ?? "",
      "Asr": timings["Asr"] ?? "",
      "Maghrib": timings["Maghrib"] ?? "",
      "Isha": timings["Isha"] ?? "",
    };
  }

  String? _calculateSabahTime(Map<String, dynamic> timings, DateTime date) {
    final sunriseRaw = timings['Sunrise'];
    if (sunriseRaw is! String) return null;

    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(sunriseRaw);
    if (match == null) return null;

    final sunriseHour = int.parse(match.group(1)!);
    final sunriseMinute = int.parse(match.group(2)!);

    final sunriseTime =
    DateTime(date.year, date.month, date.day, sunriseHour, sunriseMinute);
    final sabahTime = sunriseTime.subtract(const Duration(hours: 1));

    final hour = sabahTime.hour.toString().padLeft(2, '0');
    final minute = sabahTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  List<Widget> _buildPrayerList(BuildContext context) {
    if (_selectedDayTimings == null) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 24),
          child: Text(
            _statusMessage ?? AppLocalizations.of(context)!.noDataForDay,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ];
    }

    final displayTimings =
    _formatDisplayTimings(_selectedDayTimings!, _selectedDay);
    const order = ['Sabah', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return order
        .where((key) => displayTimings.containsKey(key))
        .map(
          (key) => Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Icon(
            Icons.access_time,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Text(_translatePrayerName(context, key)),
          trailing: Text(displayTimings[key] ?? ''),
        ),
      ),
    )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.calendarTitle),
      ),
      bottomNavigationBar: const MainBottomNavBar(currentTab: NavigationTab.calendar),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<CalendarFormat>(
              segments: [
                ButtonSegment(
                  value: CalendarFormat.week,
                  icon: Icon(Icons.view_week),
                  label: Text(loc.weeklyLabel),
                ),
                ButtonSegment(
                  value: CalendarFormat.month,
                  icon: Icon(Icons.calendar_view_month),
                  label: Text(loc.monthlyLabel),
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
              locale: Localizations.localeOf(context).toLanguageTag(),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              headerStyle: const HeaderStyle(formatButtonVisible: false),
              availableCalendarFormats: {
                CalendarFormat.month: loc.monthlyLabel,
                CalendarFormat.week: loc.weeklyLabel,
              },
              onDaySelected: (selectedDay, focusedDay) {
                final normalizedDay = DateTime(
                  selectedDay.year,
                  selectedDay.month,
                  selectedDay.day,
                );

                setState(() {
                  _selectedDay = normalizedDay;
                  _focusedDay = focusedDay;
                  _selectedDayTimings = _monthlyTimings[normalizedDay];
                });

                if (_selectedDayTimings == null) {
                  _fetchPrayerTimesForDate(normalizedDay);
                }
              },
              onPageChanged: (focusedDay) {
                if (_focusedDay.month != focusedDay.month ||
                    _focusedDay.year != focusedDay.year) {
                  _focusedDay = focusedDay;
                  _fetchMonthlyPrayerTimes(focusedDay);
                } else {
                  _focusedDay = focusedDay;
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                children: [
                  Text(
                    loc.selectedDayTimes,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ..._buildPrayerList(context),
                  const SizedBox(height: 16),
                  Text(
                    loc.monthlyLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ..._buildMonthlyTimingsList(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMonthlyTimingsList(BuildContext context) {
    if (_monthlyTimings.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _statusMessage ?? AppLocalizations.of(context)!.noDataForDay,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ];
    }

    final entries = _monthlyTimings.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final order = ['Sabah', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final locale = Localizations.localeOf(context).toLanguageTag();

    return entries.map((entry) {
      final displayTimings = _formatDisplayTimings(entry.value, entry.key);
      final dateLabel = DateFormat('d MMMM yyyy', locale).format(entry.key);

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              ...order.map(
                    (key) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.access_time),
                  title: Text(_translatePrayerName(context, key)),
                  trailing: Text(displayTimings[key] ?? ''),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}