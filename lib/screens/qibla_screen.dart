import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({Key? key}) : super(key: key);

  @override
  _QiblaScreenState createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  double _currentHeading = 0.0;
  double _qiblaDirection = 0.0;
  double _distanceToQibla = 0.0;
  bool _isQiblaFound = false;
  bool _isLoading = true;

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final LocationService _locationService = LocationService();

  // Kâbe'nin koordinatları
  static const double _kaabaLatitude = 21.4225;
  static const double _kaabaLongitude = 39.8262;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _initializeCompass();
    _calculateQiblaDirection();
  }

  Future<void> _initializeCompass() async {
    try {
      // Manyetik sensör dinleyicisi
      magnetometerEvents.listen((MagnetometerEvent event) {
        if (mounted) {
          setState(() {
            _currentHeading = _calculateHeading(event.x, event.y);
            _checkQiblaDirection();
          });
        }
      });
    } catch (e) {
      print('Compass initialization error: $e');
    }
  }

  double _calculateHeading(double x, double y) {
    double heading = math.atan2(y, x) * (180 / math.pi);
    return heading < 0 ? heading + 360 : heading;
  }

  Future<void> _calculateQiblaDirection() async {
    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        final qiblaAngle = _calculateBearing(
          location.latitude!,
          location.longitude!,
          _kaabaLatitude,
          _kaabaLongitude,
        );

        final distance = _calculateDistance(
          location.latitude!,
          location.longitude!,
          _kaabaLatitude,
          _kaabaLongitude,
        );

        if (mounted) {
          setState(() {
            _qiblaDirection = qiblaAngle;
            _distanceToQibla = distance;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error calculating qibla direction: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);
    final deltaLon = _degreesToRadians(lon2 - lon1);

    final y = math.sin(deltaLon) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) -
        math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(deltaLon);

    double bearing = math.atan2(y, x) * (180 / math.pi);
    return (bearing + 360) % 360;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // km
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);
    final deltaLat = _degreesToRadians(lat2 - lat1);
    final deltaLon = _degreesToRadians(lon2 - lon1);

    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
            math.sin(deltaLon / 2) * math.sin(deltaLon / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  void _checkQiblaDirection() {
    final difference = (_currentHeading - _qiblaDirection).abs();
    final isQibla = difference < 5 || difference > 355; // 5 derece tolerans

    if (isQibla != _isQiblaFound) {
      setState(() {
        _isQiblaFound = isQibla;
      });

      if (isQibla) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  String _getDirectionText() {
    if (_isQiblaFound) {
      return 'Kıbleye Yöneldiniz';
    } else {
      final difference = _qiblaDirection - _currentHeading;
      if (difference > 0 && difference < 180) {
        return 'Sağa Dönün';
      } else {
        return 'Sola Dönün';
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C27),
        title: const Text(
          'Kıble Pusulası',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pusula Göstergesi
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pusula Dairesi
                      Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2C2C38),
                          border: Border.all(
                            color: Colors.teal,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      // Yön Göstergeleri
                      ..._buildDirectionMarkers(),

                      // Kıble Yönü İşareti
                      Transform.rotate(
                        angle: _degreesToRadians(_qiblaDirection - _currentHeading),
                        child: Container(
                          width: 4,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Merkez Nokta
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),

                      // Kıble Bulunduğunda Animasyon
                      if (_isQiblaFound)
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.withOpacity(0.3),
                              border: Border.all(
                                color: Colors.green,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Yönlendirme Metni
                Text(
                  _getDirectionText(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isQiblaFound ? Colors.green : Colors.amber,
                  ),
                ),

                const SizedBox(height: 20),

                // Mesafe Bilgisi
                Text(
                  'Kâbe\'ye Mesafe: ${_distanceToQibla.toStringAsFixed(0)} km',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),

          // Kıble Bulundu Mesajı
          if (_isQiblaFound)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Şu anda kıbleye doğru bakıyorsunuz',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildDirectionMarkers() {
    final directions = [
      {'label': 'N', 'angle': 0},
      {'label': 'E', 'angle': 90},
      {'label': 'S', 'angle': 180},
      {'label': 'W', 'angle': 270},
    ];

    return directions.map((direction) {
      final angle = _degreesToRadians(
          (direction['angle'] as num).toDouble() - _currentHeading
      );

      return Transform.rotate(
        angle: angle,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  direction['label'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 2,
                  height: 15,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}