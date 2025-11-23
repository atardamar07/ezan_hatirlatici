import 'package:flutter/material.dart';

import '../services/ad_service.dart';
import '../services/ad_service_base.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C27),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(loc.notificationsTitle, style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            Text(
              loc.notificationInfoLine1,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              loc.notificationInfoLine2,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            _buildCard(
              title: loc.notificationStatus,
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
                        loc.notificationPermission,
                        status?.notificationsEnabled ?? false,
                        okText: loc.permissionGranted,
                        failText: loc.permissionDenied,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow(
                        loc.exactAlarmPermission,
                        status?.exactAlarmsEnabled ?? false,
                        okText: loc.schedulingActive,
                        failText: loc.exactAlarmDisabled,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow(
                        okText: loc.schedulingActive,
                        failText: loc.exactAlarmDisabled,
                        status?.soundEnabled ?? false,
                        okText: loc.soundOn,
                        failText: loc.soundOff,
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildCard(
              title: loc.adControl,
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
                        loc.sdkInitialized,
                        status?.initialized ?? false,
                        loc.sdkInitialized,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow(
                        loc.bannerAd,
                        status?.bannerReady ?? false,
                        okText: loc.loaded,
                        failText: loc.notLoaded,
                      ),
                      const SizedBox(height: 12),
                      _buildStatusRow(
                        loc.interstitialAd,
                        status?.interstitialReady ?? false,
                        okText: status?.interstitialShowing == true
                            ? loc.showing
                            : loc.statusReady,
                        failText: loc.notReady,
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