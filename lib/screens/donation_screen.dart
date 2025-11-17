import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
        _showErrorDialog('Bağış işlemi başarısız oldu: $e');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.favorite, color: Colors.green),
          SizedBox(width: 8),
          Text('Teşekkürler!'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: const [
          Icon(Icons.check_circle, color: Colors.green, size: 64),
          SizedBox(height: 16),
          Text('Bağışınız için çok teşekkür ederiz!',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
          SizedBox(height: 8),
          Text('Artık uygulamada reklam görmeyeceksiniz.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ]),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Text('Hata'),
        ]),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tamam')),
        ],
      ),
    );
  }

  /* ---------- BUILD ---------- */
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return _webBody();

    final products = DonationService.getDonationProducts();
    return _mobileBody(products);
  }

  /* ---------- WEB UYARISI ---------- */
  Widget _webBody() {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C27),
        title: const Text('Bağış Yap',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Card(
          color: const Color(0xFF2C2C38),
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: const [
              Icon(Icons.mobile_friendly, color: Colors.teal, size: 48),
              SizedBox(height: 16),
              Text('Bağış İşlemleri Mobil Uygulamada Mevcut',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                  'Uygulamayı Android veya iOS cihazınızdan kullanarak bağış yapabilirsiniz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
            ]),
          ),
        ),
      ),
    );
  }

  /* ---------- MOBIL EKRAN ---------- */
  Widget _mobileBody(List<Map<String, dynamic>> products) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C27),
        title: const Text('Bağış Yap',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_donationInfo != null) _statusCard(),
            const SizedBox(height: 20),
            const Text('Destek Seçenekleri',
                style: TextStyle(
                    color: Colors.white,
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
    return Card(
      color: _donationInfo!['hasDonated'] ? Colors.green.shade800 : const Color(0xFF2C2C38),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              _donationInfo!['hasDonated'] ? Icons.favorite : Icons.favorite_border,
              color: _donationInfo!['hasDonated'] ? Colors.green : Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              _donationInfo!['hasDonated']
                  ? 'Bağış yaptığınız için teşekkürler!'
                  : 'Uygulamayı desteklemek ister misiniz?',
              style: const TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (_donationInfo!['hasDonated'] && _donationInfo!['isActive'])
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('Reklamsız deneyimin keyfini çıkarın',
                    style: TextStyle(color: Colors.green)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard() {
    return const Card(
      color: Color(0xFF2C2C38),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.info, color: Colors.teal),
            SizedBox(height: 8),
            Text(
              'Bağışlarınız uygulamanın geliştirilmesi ve sunucu masraflarının karşılanmasında kullanılacaktır.',
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Bağış yaptıktan sonra 30 gün boyunca reklam gösterilmeyecektir.',
              style: TextStyle(
                  color: Colors.teal, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _donationCard(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: const Color(0xFF2C2C38),
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
                    color: Colors.teal.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(product['icon'], size: 30, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['title'],
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(product['description'],
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(product['price'],
                        style: const TextStyle(
                            color: Colors.amber,
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
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(80, 32)),
                      child: const Text('Bağış Yap',
                          style: TextStyle(fontSize: 12)),
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