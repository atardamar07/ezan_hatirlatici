import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../services/ad_free.dart';
import '../services/ad_service.dart';
import '../services/donation_service.dart';

/// Reklamsız kullanım: ödüllü reklam (4 reklam = 12 saat) veya ömür boyu lisans
class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final _donations = DonationService();
  final _ads = AdService();
  SharedPreferences? _prefs;
  Timer? _ticker;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) setState(() => _prefs = p);
    });
    if (!kIsWeb) {
      _ads.initialize(); // tekil servis: başlatıldıysa aynı sonucu döndürür
      _donations.initialize().then(
        (_) {
          if (mounted) setState(() {}); // mağaza fiyatı geldi
        },
        onError: (Object e) => debugPrint('IAP init failed: $e'),
      );
    }
    // Kalan reklamsız süre ekranda dakikada bir güncellensin
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
      );

  Future<void> _watchAd() async {
    setState(() => _busy = true);
    final earned = await _ads.showRewardedAd();
    if (earned == true) await AdFree.recordRewardedAd(_prefs!, DateTime.now());
    if (!mounted) return;
    setState(() => _busy = false);
    if (earned == null) _snack(AppLocalizations.of(context)!.adNotReady);
  }

  Future<void> _buyLifetime() async {
    setState(() => _busy = true);
    try {
      final completed = await _donations.makeDonation(DonationService.lifetimeProductId);
      if (completed && mounted) _snack(AppLocalizations.of(context)!.lifetimeActive);
    } catch (e) {
      if (mounted) _snack(AppLocalizations.of(context)!.donationFailed('$e'));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final prefs = _prefs;

    if (prefs == null) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.adFreeTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final now = DateTime.now();
    final lifetime = AdFree.hasLifetime(prefs);
    final until = AdFree.until(prefs);
    final remaining = until != null && until.isAfter(now) ? until.difference(now) : null;
    final watched = AdFree.watchedCount(prefs);
    final price = _donations.priceOf(DonationService.lifetimeProductId);
    final active = lifetime || remaining != null;

    return Scaffold(
      appBar: AppBar(title: Text(loc.adFreeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: active ? scheme.primaryContainer : null,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(
                lifetime
                    ? Icons.workspace_premium
                    : remaining != null
                        ? Icons.timer_outlined
                        : Icons.favorite_outline,
                color: scheme.primary,
              ),
              title: Text(
                lifetime
                    ? loc.lifetimeActive
                    : remaining != null
                        ? loc.adFreeActiveFor(remaining.inHours, remaining.inMinutes % 60)
                        : loc.adFreeIntro,
              ),
            ),
          ),
          if (!lifetime) ...[
            const SizedBox(height: 12),
            _OptionCard(
              icon: Icons.ondemand_video,
              title: loc.watchAdsTitle,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: watched / AdFree.adsPerReward,
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(loc.watchAdsProgress(watched), style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _busy || kIsWeb ? null : _watchAd,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(loc.watchAdButton),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _OptionCard(
              icon: Icons.workspace_premium,
              title: loc.lifetimeTitle,
              trailing: price == null
                  ? null
                  : Text(
                      price,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: scheme.primary, fontWeight: FontWeight.bold),
                    ),
              children: [
                Text(loc.lifetimeDescription, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                // Fiyat mağazadan gelmeden (mağaza yok/ürün yüklenmedi) satın alma açılmaz
                FilledButton.tonalIcon(
                  onPressed: _busy || price == null ? null : _buyLifetime,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(loc.buyButton),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
