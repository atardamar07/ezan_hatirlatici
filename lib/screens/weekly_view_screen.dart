import 'package:flutter/material.dart';

import '../navigation/bottom_nav_bar.dart';

class WeeklyViewScreen extends StatelessWidget {
  const WeeklyViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C27),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Haftalık Görünüm', style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: const MainBottomNavBar(currentTab: NavigationTab.weekly),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Haftalık namaz vakti takvimi yakında burada olacak.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}