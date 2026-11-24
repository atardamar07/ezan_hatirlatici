import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Alt sekmeler: uygulamanın özü (vakitler, kıble, takvim) tek dokunuşta
enum NavigationTab { home, qibla, calendar }

class MainBottomNavBar extends StatelessWidget {
  final NavigationTab currentTab;

  const MainBottomNavBar({super.key, required this.currentTab});

  static const _routes = ['/home', '/qibla', '/calendar'];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return NavigationBar(
      selectedIndex: currentTab.index,
      onDestinationSelected: (index) {
        if (index == currentTab.index) return;
        Navigator.pushReplacementNamed(context, _routes[index]);
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.access_time),
          selectedIcon: const Icon(Icons.access_time_filled),
          label: loc.home,
        ),
        NavigationDestination(
          icon: const Icon(Icons.explore_outlined),
          selectedIcon: const Icon(Icons.explore),
          label: loc.qiblaTab,
        ),
        NavigationDestination(
          icon: const Icon(Icons.calendar_month_outlined),
          selectedIcon: const Icon(Icons.calendar_month),
          label: loc.calendarTitle,
        ),
      ],
    );
  }
}
