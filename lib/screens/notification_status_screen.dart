import 'package:flutter/material.dart';

import '../services/ad_service.dart';
import '../services/ad_service_base.dart';
import '../services/notification_service.dart';

class NotificationStatusScreen extends StatefulWidget {
  const NotificationStatusScreen({super.key});

  @override
  State<NotificationStatusScreen> createState() =>
      _NotificationStatusScreenState();
}

class _NotificationStatusScreenState extends State<NotificationStatusScreen> {
  late Future<NotificationStatus> _notificationStatusFuture;
  late Future<AdStatus> _adStatusFuture;

  @override
  void initState() {
    super.initState();
    _notificationStatusFuture = NotificationService.getStatus();
    _adStatusFuture = AdService().getStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C27),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Bildirimler', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            const Text(
              'Namaz hatırlatıcılarını etkinleştirdiğinizde uyarılar zamanında gelir.',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bildirim izinlerini cihaz ayarlarınızdan yönetebilir, sesli ezan bildirimlerini açabilirsiniz.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            _buildCard(
              title: 'Bildirim durumu',
              child: FutureBuilder<NotificationStatus>(
                future: _notificationStatusFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    );
                  }

                  final status = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusRow(
                        'Bildirim izni',
                        status?.notificationsEnabled ?? false,
                        okText: 'İzin verildi',
                        failText: 'İzin kapalı',
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow(
                        'Exact alarm izni',
                        status?.exactAlarmsEnabled ?? false,
                        okText: 'Planlama aktif',
                        failText: 'Exact alarm kapalı',
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow(
                        'Sesli bildirim',
                        status?.soundEnabled ?? false,
                        okText: 'Ezan sesi açık',
                        failText: 'Ses kapalı',
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: 'Reklam kontrolü',
              child: FutureBuilder<AdStatus>(
                future: _adStatusFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    );
                  }

                  final status = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusRow(
                        'SDK başlatıldı',
                        status?.initialized ?? false,
                        okText: 'Hazır',
                        failText: 'Başlatma bekleniyor',
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow(
                        'Banner',
                        status?.bannerReady ?? false,
                        okText: 'Yüklendi',
                        failText: 'Yüklenmedi',
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow(
                        'Geçiş reklamı',
                        status?.interstitialReady ?? false,
                        okText: status?.interstitialShowing == true
                            ? 'Gösteriliyor'
                            : 'Hazır',
                        failText: 'Hazır değil',
                        isActive: status?.interstitialShowing ?? false,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF242433),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildStatusRow(
      String label,
      bool value, {
        required String okText,
        required String failText,
        bool isActive = false,
      }) {
    final color = value ? Colors.tealAccent : Colors.orangeAccent;

    return Row(
      children: [
        Icon(
          value ? Icons.check_circle : Icons.error_outline,
          color: isActive ? Colors.amber : color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value ? okText : failText,
                style: TextStyle(color: color.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}