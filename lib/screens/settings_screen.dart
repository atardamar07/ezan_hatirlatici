import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _themeMode = widget.currentMode;
  }

  Future<void> _updateThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    widget.onThemeModeChanged(mode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
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
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                _buildThemeTile(
                  title: 'Sistem Teması',
                  subtitle: 'Cihaz ayarlarına göre',
                  mode: ThemeMode.system,
                  icon: Icons.brightness_auto,
                ),
                const Divider(height: 1),
                _buildThemeTile(
                  title: 'Açık Tema',
                  subtitle: 'Gündüz görünümü',
                  mode: ThemeMode.light,
                  icon: Icons.light_mode,
                ),
                const Divider(height: 1),
                _buildThemeTile(
                  title: 'Koyu Tema',
                  subtitle: 'Gece görünümü',
                  mode: ThemeMode.dark,
                  icon: Icons.dark_mode,
                ),
              ],
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