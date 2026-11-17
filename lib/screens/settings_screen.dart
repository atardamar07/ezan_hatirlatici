import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../services/ad_service.dart';
import '../services/notification_scheduler.dart';
import '../services/prayer_times_api.dart';
import '../settings/notification_model.dart';
import '../settings/widgets/notification_tile.dart';
import '../settings/widgets/status_badge.dart';

class SettingsScreen extends StatefulWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const SettingsScreen({
    super.key,
    required this.currentMode,
    required this.onThemeModeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode _themeMode;
  List<PrayerNotificationSetting> _prayerSettings = [];
  double _quietHoursDuration = 6;
  int _preAlertMinutes = 10;
  int _method = PrayerTimesApi.diyanetMethodId;
  bool _showAdPrivacyOptions = false;
  bool _locationReady = false;
  bool _internetReady = true;

  String _localizedPrayerTitle(AppLocalizations loc, String key) {
    switch (key) {
      case 'imsak':
        return loc.fajr;
      case 'sabah':
        return loc.sabah; // ana sayfadaki "Sabah" (güneşten 1 saat önce)
      case 'ogle':
        return loc.dhuhr;
      case 'ikindi':
        return loc.asr;
      case 'aksam':
        return loc.maghrib;
      case 'yatsi':
        return loc.isha;
      default:
        return key;
    }
  }

  @override
  void initState() {
    super.initState();
    _themeMode = widget.currentMode;
    _prayerSettings = _defaultPrayerSettings();
    _loadSavedPreferences();
    _checkStatuses();
    AdService().isPrivacyOptionsRequired().then((required) {
      if (mounted && required) setState(() => _showAdPrivacyOptions = true);
    });
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSettings = prefs.getString('prayerNotificationSettings');
    final savedQuietHours = prefs.getDouble('quietHoursDuration');
    final savedPreAlert = prefs.getInt('preAlertMinutes');

    var updatedSettings = _defaultPrayerSettings();
    if (savedSettings != null) {
      try {
        final decoded = jsonDecode(savedSettings) as List<dynamic>;
        for (final item in decoded) {
          final parsed = PrayerNotificationSetting.fromJson(
            Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
          );
          final index =
          updatedSettings.indexWhere((setting) => setting.key == parsed.key);
          if (index != -1) {
            updatedSettings[index] = updatedSettings[index].copyWith(
              isEnabled: parsed.isEnabled,
              time: parsed.time,
            );
          } else {
            updatedSettings.add(parsed);
          }
        }
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _prayerSettings = updatedSettings;
      _quietHoursDuration = savedQuietHours ?? _quietHoursDuration;
      _preAlertMinutes = savedPreAlert ?? _preAlertMinutes;
      _method = prefs.getInt('calculationMethod') ?? _method;
    });
  }

  Future<void> _showCalculationMethods() async {
    final loc = AppLocalizations.of(context)!;
    final methods = PrayerTimesApi().getCalculationMethods(loc);

    final selected = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(loc.calculationMethod),
        children: [
          for (final method in methods)
            ListTile(
              title: Text(method['name'] as String),
              subtitle: Text(method['description'] as String),
              trailing: method['id'] == _method ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(context, method['id'] as int),
            ),
        ],
      ),
    );

    if (selected == null || selected == _method) return;
    setState(() => _method = selected);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calculationMethod', selected);
    NotificationScheduler().scheduleAllPrayerNotifications();
  }

  Future<void> _updateThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    widget.onThemeModeChanged(mode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  Future<void> _checkStatuses() async {
    final permission = await Geolocator.checkPermission();
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    final locationOk = serviceEnabled &&
        (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse);

    bool internetOk = true;
    try {
      final result = await InternetAddress.lookup('example.com');
      internetOk = result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      internetOk = false;
    }

    if (!mounted) return;
    setState(() {
      _locationReady = locationOk;
      _internetReady = internetOk;
    });
  }

  List<PrayerNotificationSetting> _defaultPrayerSettings() {
    return [
      // Varsayılan kapalı: yüksek enlemlerde imsak gece yarısına denk gelebiliyor
      PrayerNotificationSetting(
        key: 'imsak',
        title: 'İmsak',
        isEnabled: false,
        time: const TimeOfDay(hour: 5, minute: 30),
      ),
      PrayerNotificationSetting(
        key: 'sabah',
        title: 'Sabah',
        isEnabled: true,
        time: const TimeOfDay(hour: 6, minute: 15),
      ),
      PrayerNotificationSetting(
        key: 'ogle',
        title: 'Öğle',
        isEnabled: true,
        time: const TimeOfDay(hour: 13, minute: 0),
      ),
      PrayerNotificationSetting(
        key: 'ikindi',
        title: 'İkindi',
        isEnabled: true,
        time: const TimeOfDay(hour: 16, minute: 45),
      ),
      PrayerNotificationSetting(
        key: 'aksam',
        title: 'Akşam',
        isEnabled: true,
        time: const TimeOfDay(hour: 19, minute: 30),
      ),
      PrayerNotificationSetting(
        key: 'yatsi',
        title: 'Yatsı',
        isEnabled: true,
        time: const TimeOfDay(hour: 21, minute: 15),
      ),
    ];
  }

  Future<void> _saveNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'prayerNotificationSettings',
      jsonEncode(_prayerSettings.map((e) => e.toJson()).toList()),
    );
    await prefs.setDouble('quietHoursDuration', _quietHoursDuration);
    await prefs.setInt('preAlertMinutes', _preAlertMinutes);
  }

  Future<void> _toggleNotification(int index, bool value) async {
    setState(() {
      _prayerSettings[index] =
          _prayerSettings[index].copyWith(isEnabled: value);
    });
    await _saveNotificationPreferences();
    NotificationScheduler().scheduleAllPrayerNotifications();
  }

  Future<void> _updateQuietHours(double value) async {
    setState(() => _quietHoursDuration = value);
    await _saveNotificationPreferences();
  }

  Future<void> _updatePreAlertMinutes(int? value) async {
    if (value == null) return;
    setState(() => _preAlertMinutes = value);
    await _saveNotificationPreferences();
    NotificationScheduler().scheduleAllPrayerNotifications();
  }

  Widget _buildValueBadge(String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.secondary.withOpacity(0.35),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settings),
        backgroundColor: colorScheme.surface,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              loc.settings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                StatusBadge(
                  icon: _locationReady
                      ? Icons.my_location_rounded
                      : Icons.location_off,
                  label: _locationReady
                      ? loc.locationStatusOn
                      : loc.locationStatusOff,
                  isActive: _locationReady,
                  colorScheme: colorScheme,
                ),
                StatusBadge(
                  icon: _internetReady ? Icons.wifi_tethering : Icons.wifi_off,
                  label:
                  _internetReady ? loc.internetStatusOn : loc.internetStatusOff,
                  isActive: _internetReady,
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: Text(loc.calculationMethod),
              subtitle: Text(
                PrayerTimesApi()
                    .getCalculationMethods(loc)
                    .firstWhere(
                      (m) => m['id'] == _method,
                      orElse: () => {'name': '$_method'},
                    )['name'] as String,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showCalculationMethods,
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: Text(loc.prayerNotificationsTitle),
                  subtitle: Text(loc.prayerNotificationsSubtitle),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.notifications_active,
                        color: colorScheme.onPrimaryContainer),
                  ),
                ),
                const Divider(height: 1),
                for (var i = 0; i < _prayerSettings.length; i++) ...[
                  NotificationTile(
                    setting: _prayerSettings[i],
                    onToggle: (value) => _toggleNotification(i, value),
                    enabledLabel: loc.notificationEnabled,
                    disabledLabel: loc.notificationDisabled,
                    titleOverride: _localizedPrayerTitle(
                      loc,
                      _prayerSettings[i].key,
                    ),
                  ),
                  if (i != _prayerSettings.length - 1)
                    const Divider(height: 1),
                ],
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: Text(loc.notificationOptionsTitle),
                  subtitle: Text(loc.notificationOptionsSubtitle),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.tune, color: colorScheme.onSurface),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              loc.quietHoursLabel,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          _buildValueBadge(
                            loc.quietHoursShort(_quietHoursDuration.round()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _quietHoursDuration,
                        min: 0,
                        max: 12,
                        divisions: 12,
                        label: loc.quietHoursLong(_quietHoursDuration.round()),
                        onChanged: (value) => _updateQuietHours(value),
                        activeColor: colorScheme.primary,
                        inactiveColor: colorScheme.primary.withOpacity(0.2),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              loc.preAlert,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          _buildValueBadge(
                            _preAlertMinutes == 0
                                ? loc.preAlertOff
                                : loc.preAlertMinutes(_preAlertMinutes),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _preAlertMinutes,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        items: const [0, 5, 10, 15, 30]
                            .map(
                              (minutes) => DropdownMenuItem<int>(
                            value: minutes,
                            child: Text(
                              minutes == 0
                                  ? loc.preAlertOff
                                  : loc.preAlertMinutes(minutes),
                            ),
                          ),
                        )
                            .toList(),
                        onChanged: _updatePreAlertMinutes,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildThemeTile(
                  title: loc.systemTheme,
                  subtitle: loc.systemThemeSubtitle,
                  mode: ThemeMode.system,
                  icon: Icons.brightness_auto,
                ),
                const Divider(height: 1),
                _buildThemeTile(
                  title: loc.lightTheme,
                  subtitle: loc.lightThemeSubtitle,
                  mode: ThemeMode.light,
                  icon: Icons.light_mode,
                ),
                const Divider(height: 1),
                _buildThemeTile(
                  title: loc.darkTheme,
                  subtitle: loc.darkThemeSubtitle,
                  mode: ThemeMode.dark,
                  icon: Icons.dark_mode,
                ),
              ],
            ),
          ),
          // GDPR: onay gereken bölgelerde kullanıcı reklam onayını buradan değiştirebilmeli
          if (_showAdPrivacyOptions)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: Text(loc.adPrivacyOptions),
                trailing: const Icon(Icons.chevron_right),
                onTap: AdService().showPrivacyOptions,
              ),
            ),
        ],
      ),
    );
  }

  RadioListTile<ThemeMode> _buildThemeTile({
    required String title,
    required String subtitle,
    required ThemeMode mode,
    required IconData icon,
  }) {
    return RadioListTile<ThemeMode>(
      value: mode,
      groupValue: _themeMode,
      onChanged: (value) {
        if (value != null) {
          _updateThemeMode(value);
        }
      },
      title: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Text(title),
        ],
      ),
      subtitle: Text(subtitle),
    );
  }
}