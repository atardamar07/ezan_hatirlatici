import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../l10n/app_localizations.dart';
import '../services/donation_service.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({Key? key}) : super(key: key);

  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final DonationService _donationService = DonationService();
  Map<String, dynamic>? _donationInfo;
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initializeDonationService();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _initializeDonationService() async {
    try {
      await _donationService.initialize();
      final donationInfo = await DonationService.getDonationInfo();
      if (mounted) {
        setState(() {
          _donationInfo = donationInfo;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Donation service initialization error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _makeDonation(String productId) async {
    if (kIsWeb) return;
    setState(() => _isProcessing = true);
    try {
      await _donationService.makeDonation(productId);
      final donationInfo = await DonationService.getDonationInfo();
      if (mounted) {
        setState(() {
          _donationInfo = donationInfo;
          _isProcessing = false;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showErrorDialog(AppLocalizations.of(context)!.donationFailed('$e'));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(children: [
          Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.thankYou),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 64),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context)!.donationSuccess,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(AppLocalizations.of(context)!.noAds,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(AppLocalizations.of(context)!.continueText),
          ),
        ],
      ),
    );
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(children: [
          Icon(Icons.error, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.errorTitle),
        ]),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.continueText)),
        ],
      ),
    );
  }

  /* ---------- BUILD ---------- */
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return _webBody();

    final products = DonationService.getDonationProducts(AppLocalizations.of(context)!);
    return _mobileBody(products);
  }
  /* ---------- WEB UYARISI ---------- */
  Widget _webBody() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        title: Text(AppLocalizations.of(context)!.donationTitle),
      ),
      body: Center(
        child: Card(
          color: colors.surface,
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.mobile_friendly, color: colors.primary, size: 48),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.donationsForWeb,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                      color: colors.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      AppLocalizations.of(context)!.donateInfo,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.7))),
            ]),
          ),
        ),
      ),
    );
  }
  /* ---------- MOBIL EKRAN ---------- */
  Widget _mobileBody(List<Map<String, dynamic>> products) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        title: Text(AppLocalizations.of(context)!.donationTitle),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_donationInfo != null) _statusCard(),
            const SizedBox(height: 20),
            Text(AppLocalizations.of(context)!.supportApp,
                style: theme.textTheme.titleLarge?.copyWith(
                    color: colors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            for (final product in products) _donationCard(product),
            const SizedBox(height: 20),
            _infoCard(),
          ],
        ),
      ),
    );
  }

  Widget _statusCard() {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: _donationInfo!['hasDonated'] ? colors.primary.withOpacity(0.15) : colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _donationInfo!['hasDonated'] ? Icons.favorite : Icons.favorite_border,
              color: _donationInfo!['hasDonated'] ? colors.primary : colors.onSurface.withOpacity(0.6),
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              _donationInfo!['hasDonated']
                  ? AppLocalizations.of(context)!.hasDonatedThanks
                  : AppLocalizations.of(context)!.supportApp,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colors.onSurface, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_donationInfo!['hasDonated'] && _donationInfo!['isActive'])
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(AppLocalizations.of(context)!.adFreeExperience,
                    style: TextStyle(color: colors.primary)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Card(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.info, color: colors.primary),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.supportOptionalText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.donationInfoText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.noAdsFor30Days,
              style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.primary, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _donationCard(Map<String, dynamic> product) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: colors.surface,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _isProcessing ? null : () => _makeDonation(product['id']),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(product['icon'], size: 30, color: colors.onPrimary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['title'],
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: colors.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(product['description'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface.withOpacity(0.7), fontSize: 14)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(product['price'],
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.secondary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    _isProcessing
                        ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                        CircularProgressIndicator(strokeWidth: 2))
                        : ElevatedButton(
                      onPressed: () => _makeDonation(product['id']),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          minimumSize: const Size(80, 32)),
                      child: Text(AppLocalizations.of(context)!.donateButton,
                          style: TextStyle(fontSize: 12, color: colors.onPrimary)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}