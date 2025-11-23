import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum NavigationTab { home, calendar, weekly }

class MainBottomNavBar extends StatelessWidget {
  final NavigationTab currentTab;

  const MainBottomNavBar({super.key, required this.currentTab});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return NavigationBar(
      selectedIndex: currentTab.index,
      onDestinationSelected: (index) {
        final selected = NavigationTab.values[index];
        if (selected == currentTab) return;

        switch (selected) {
          case NavigationTab.home:
            Navigator.pushReplacementNamed(context, '/home');
            break;
          case NavigationTab.calendar:
            Navigator.pushReplacementNamed(context, '/calendar');
            break;
          case NavigationTab.weekly:
            Navigator.pushReplacementNamed(context, '/weekly_view');
            break;
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: loc?.home ?? 'Ana Sayfa',
        ),
        const NavigationDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_month),
          label: 'Takvim',
        ),
        const NavigationDestination(
          icon: Icon(Icons.view_week_outlined),
          selectedIcon: Icon(Icons.view_week),
          label: 'Haftalık',
        ),
      ],
    );
  }
}