import 'package:flutter/material.dart';

class NotificationStatusScreen extends StatelessWidget {
  const NotificationStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C27),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Bildirimler', style: TextStyle(color: Colors.white)),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12),
            Text(
              'Namaz hatırlatıcılarını etkinleştirdiğinizde uyarılar zamanında gelir.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Bildirim izinlerini cihaz ayarlarınızdan yönetebilir, sesli ezan bildirimlerini açabilirsiniz.',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}