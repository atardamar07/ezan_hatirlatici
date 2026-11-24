import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../l10n/app_localizations.dart';
import '../navigation/bottom_nav_bar.dart';
import '../services/prayer_times_api.dart';
import '../widgets/prayer_times_list.dart';

/// Hicri ay adları (Aladhan ay numarası 1 = Muharrem)
const _hijriMonths = {
  'tr': ['Muharrem', 'Safer', 'Rebiülevvel', 'Rebiülahir', 'Cemaziyelevvel', 'Cemaziyelahir',
    'Recep', 'Şaban', 'Ramazan', 'Şevval', 'Zilkade', 'Zilhicce'],
  'en': ['Muharram', 'Safar', "Rabi' al-Awwal", "Rabi' al-Thani", 'Jumada al-Ula', 'Jumada al-Akhirah',
    'Rajab', "Sha'ban", 'Ramadan', 'Shawwal', "Dhu al-Qa'dah", 'Dhu al-Hijjah'],
  'de': ['Muharram', 'Safar', 'Rabi al-awwal', 'Rabi ath-thani', 'Dschumada l-ula', 'Dschumada th-thaniya',
    'Radschab', 'Schaban', 'Ramadan', 'Schawwal', "Dhu l-qa'da", 'Dhu l-hiddscha'],
  'ru': ['Мухаррам', 'Сафар', 'Раби аль-авваль', 'Раби ас-сани', 'Джумада аль-уля', 'Джумада ас-сани',
    'Раджаб', 'Шаабан', 'Рамадан', 'Шавваль', 'Зуль-када', 'Зуль-хиджа'],
  'ar': ['محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة',
    'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'],
};

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final PrayerTimesApi _prayerApi = PrayerTimesApi();
  Map<DateTime, Map<String, dynamic>> _monthlyTimings = {};
  Map<String, dynamic>? _selectedDayTimings;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = _dateOnly(DateTime.now());
  // Haftalık başlar ki vakitler görünsün; başlıktaki düğme ya da aşağı kaydırma ayı açar
  CalendarFormat _format = CalendarFormat.week;
  bool _isLoading = true;
  bool _noLocation = false;
  String? _statusMessage;
  int _method = PrayerTimesApi.diyanetMethodId;

  double? _latitude;
  double? _longitude;
  String? _city;
  String? _country;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _method = await _prayerApi.getSavedMethodOrDefault();

    switch (prefs.getString('locationType')) {
      case 'location':
        _latitude = prefs.getDouble('latitude');
        _longitude = prefs.getDouble('longitude');
      case 'city':
        _city = prefs.getString('selectedCity');
        _country = prefs.getString('selectedCountry');
    }

    // Konum yokken başka bir şehrin vakitlerini sessizce göstermek yerine konum seçtir
    if ((_latitude == null || _longitude == null) && (_city == null || _country == null)) {
      if (mounted) {
        setState(() {
          _noLocation = true;
          _isLoading = false;
        });
      }
      return;
    }

    await _fetchMonth(_focusedDay);
  }

  Future<void> _fetchMonth(DateTime date) async {
    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final data = await _prayerApi.getMonthlyPrayerTimes(
      month: date.month,
      year: date.year,
      lat: _latitude,
      lng: _longitude,
      city: _city,
      country: _country,
      method: _method,
    );
    if (!mounted) return;

    setState(() {
      // Önceki aylar da kalsın: haftalık görünüm ay sınırını geçebiliyor
      _monthlyTimings = {..._monthlyTimings, ...?data};
      _selectedDayTimings = _monthlyTimings[_selectedDay];
      _statusMessage = data == null ? AppLocalizations.of(context)!.failedToLoadPrayerTimes : null;
      _isLoading = false;
    });

    if (data != null && _selectedDayTimings == null) await _fetchDay(_selectedDay);
  }

  Future<void> _fetchDay(DateTime day) async {
    setState(() => _isLoading = true);

    final timings = await _prayerApi.getPrayerTimesForDate(
      date: day,
      lat: _latitude,
      lng: _longitude,
      city: _city,
      country: _country,
      method: _method,
    );
    if (!mounted) return;

    setState(() {
      _selectedDayTimings = timings;
      _statusMessage = timings == null ? AppLocalizations.of(context)!.failedToLoadPrayerTimes : null;
      _isLoading = false;
    });
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    final day = _dateOnly(selected);
    setState(() {
      _selectedDay = day;
      _focusedDay = focused;
      _selectedDayTimings = _monthlyTimings[day];
      _format = CalendarFormat.week; // ay görünümü küçülsün, seçilen günün vakitleri görünsün
    });
    if (_selectedDayTimings == null) _fetchDay(day);
  }

  void _onPageChanged(DateTime focused) {
    _focusedDay = focused;
    if (!_monthlyTimings.containsKey(_dateOnly(focused))) _fetchMonth(focused);
  }

  /// Ana sayfayla aynı: Sabah = güneş doğmadan 1 saat önce
  List<String> _displayTimes(Map<String, dynamic> timings, DateTime date) {
    String hhmm(Object? raw) =>
        RegExp(r'\d{1,2}:\d{2}').firstMatch(raw is String ? raw : '')?.group(0) ?? '';

    var sabah = hhmm(timings['Fajr']);
    final sunrise = RegExp(r'(\d{1,2}):(\d{2})').firstMatch('${timings['Sunrise']}');
    if (sunrise != null) {
      final t = DateTime(date.year, date.month, date.day, int.parse(sunrise[1]!), int.parse(sunrise[2]!))
          .subtract(const Duration(hours: 1));
      sabah = DateFormat('HH:mm').format(t);
    }

    return [
      sabah,
      hhmm(timings['Dhuhr']),
      hhmm(timings['Asr']),
      hhmm(timings['Maghrib']),
      hhmm(timings['Isha']),
    ];
  }

  /// Bugün için sıradaki vaktin sırası; hepsi geçtiyse null
  int? _nextIndex(List<String> times) {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    for (var i = 0; i < times.length; i++) {
      final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(times[i]);
      if (m != null && int.parse(m[1]!) * 60 + int.parse(m[2]!) > nowMinutes) return i;
    }
    return null;
  }

  String? _hijriText(Map<String, dynamic> timings, String languageCode) {
    final day = timings['HijriDay'];
    final month = timings['HijriMonth'];
    final year = timings['HijriYear'];
    if (day is! int || month is! int || year is! int || month < 1 || month > 12) return null;
    final names = _hijriMonths[languageCode] ?? _hijriMonths['en']!;
    return '$day ${names[month - 1]} $year';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(loc.calendarTitle)),
      bottomNavigationBar: const MainBottomNavBar(currentTab: NavigationTab.calendar),
      body: _noLocation
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(loc.selectLocationOrCity, textAlign: TextAlign.center),
              ),
            )
          : Column(
              children: [
                Card(
                  margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2035, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _format,
                    availableCalendarFormats: {
                      CalendarFormat.month: loc.monthlyLabel,
                      CalendarFormat.week: loc.weeklyLabel,
                    },
                    onFormatChanged: (format) => setState(() => _format = format),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    locale: Localizations.localeOf(context).toLanguageTag(),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    onPageChanged: _onPageChanged,
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      titleTextStyle: theme.textTheme.titleMedium!,
                      formatButtonDecoration: BoxDecoration(
                        color: scheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      formatButtonTextStyle: TextStyle(color: scheme.onSecondaryContainer),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      todayDecoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: TextStyle(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      selectedTextStyle: TextStyle(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: _buildDayCard(context, loc),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildDayCard(BuildContext context, AppLocalizations loc) {
    final theme = Theme.of(context);
    final timings = _selectedDayTimings;
    if (timings == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(_statusMessage ?? loc.noDataForDay, textAlign: TextAlign.center),
      );
    }

    final locale = Localizations.localeOf(context);
    final times = _displayTimes(timings, _selectedDay);
    final names = [loc.sabah, loc.dhuhr, loc.asr, loc.maghrib, loc.isha];
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final hijri = _hijriText(timings, locale.languageCode);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat.yMMMMEEEEd(locale.toLanguageTag()).format(_selectedDay),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (isToday)
                  Chip(
                    label: Text(loc.quickActionToday),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (hijri != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.nights_stay_outlined, size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      hijri,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            PrayerTimesList(
              rows: [for (var i = 0; i < names.length; i++) (names[i], times[i])],
              highlight: isToday ? _nextIndex(times) : null,
            ),
          ],
        ),
      ),
    );
  }
}
