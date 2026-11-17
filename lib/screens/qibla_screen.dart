import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/location_service.dart';

// Kâbe'nin koordinatları
const double kaabaLatitude = 21.4225;
const double kaabaLongitude = 39.8262;

/// Telefonun üst kenarının manyetik kuzeye göre açısı (0-360, saat yönünde).
/// Android'in SensorManager.getRotationMatrix + getOrientation hesabının aynısı:
/// ivmeölçerle eğim düzeltilir, telefon eğik tutulsa da yön doğru kalır.
/// Hesaplanamıyorsa (serbest düşüş, bozuk veri) null döner.
double? compassHeading(
  double ax, double ay, double az, // ivmeölçer (yerçekimi dahil, m/s²)
  double mx, double my, double mz, // manyetometre (µT)
) {
  final hx = my * az - mz * ay;
  final hy = mz * ax - mx * az;
  final hz = mx * ay - my * ax;
  final normH = math.sqrt(hx * hx + hy * hy + hz * hz);
  final normA = math.sqrt(ax * ax + ay * ay + az * az);
  if (normH < 0.1 || normA < 1) return null;
  // atan2(H.y, (A×H).y); iki bileşen aynı ölçekte olsun diye H.y, |A| ile çarpılır
  final deg = math.atan2(hy * normA, az * hx - ax * hz) * 180 / math.pi;
  return (deg + 360) % 360;
}

/// Verilen konumdan Kâbe'ye, gerçek kuzeye göre başlangıç yönü (büyük daire, 0-360).
double qiblaBearing(double lat, double lon) {
  final lat1 = lat * math.pi / 180;
  const lat2 = kaabaLatitude * math.pi / 180;
  final deltaLon = (kaabaLongitude - lon) * math.pi / 180;

  final y = math.sin(deltaLon) * math.cos(lat2);
  final x = math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);

  return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
}

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> with SingleTickerProviderStateMixin {
  static const _compassChannel = MethodChannel('ezan_hatirlatici/compass');

  double _smoothedHeading = 0.0;
  double _qiblaDirection = 0.0;
  double _distanceToQibla = 0.0;
  double _declination = 0.0;
  bool _isQiblaFound = false;
  bool _isLoading = true;
  bool _locationFailed = false;
  bool _sensorMissing = false;
  bool _interference = false;
  bool _hasHeading = false;
  AccelerometerEvent? _gravity;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  // Update heading roughly 30 times per second for smoother compass motion
  static const Duration _headingUpdateInterval = Duration(milliseconds: 33);
  static const double _headingSmoothing = 0.15;
  DateTime _lastHeadingUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  final LocationService _locationService = LocationService();

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

  void _initializeCompass() {
    void onSensorError(Object e) {
      debugPrint('Compass sensor error: $e');
      if (mounted) setState(() => _sensorMissing = true);
    }

    _accelerometerSubscription =
        accelerometerEventStream(samplingPeriod: SensorInterval.gameInterval)
            .listen((event) => _gravity = event, onError: onSensorError);
    _magnetometerSubscription =
        magnetometerEventStream(samplingPeriod: SensorInterval.gameInterval)
            .listen(_onMagnetometer, onError: onSensorError);
  }

  void _onMagnetometer(MagnetometerEvent event) {
    final gravity = _gravity;
    if (!mounted || gravity == null) return;

    final magnetic = compassHeading(
        gravity.x, gravity.y, gravity.z, event.x, event.y, event.z);
    if (magnetic == null) return;

    final now = DateTime.now();
    if (_hasHeading && now.difference(_lastHeadingUpdate) < _headingUpdateInterval) {
      return;
    }
    _lastHeadingUpdate = now;

    // Manyetik kuzey → gerçek kuzey; kıble açısı gerçek kuzeye göre hesaplanıyor
    final heading = _normalizeAngle(magnetic + _declination);
    // Dünyanın manyetik alanı her yerde ~22-67 µT; dışındaysa parazit/kalibrasyon sorunu var
    final strength =
        math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

    setState(() {
      _smoothedHeading =
          _hasHeading ? _smoothHeading(_smoothedHeading, heading) : heading;
      _hasHeading = true;
      _interference = strength < 20 || strength > 75;
    });
    _checkQiblaDirection();
  }

  Future<void> _calculateQiblaDirection() async {
    setState(() {
      _isLoading = true;
      _locationFailed = false;
    });

    double? lat;
    double? lon;
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      lat = position.latitude;
      lon = position.longitude;
    } else {
      // GPS yoksa ana sayfanın kaydettiği son konumu kullan
      final prefs = await SharedPreferences.getInstance();
      lat = prefs.getDouble('latitude');
      lon = prefs.getDouble('longitude');
    }

    if (lat == null || lon == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _locationFailed = true;
        });
      }
      return;
    }

    double declination = 0;
    try {
      declination = await _compassChannel
              .invokeMethod<double>('declination', {'lat': lat, 'lon': lon}) ??
          0;
    } catch (e) {
      // Android dışı platformlarda kanal yok; manyetik kuzeyle devam edilir
      debugPrint('Declination unavailable: $e');
    }

    final bearing = qiblaBearing(lat, lon);
    final distance = _calculateDistance(lat, lon, kaabaLatitude, kaabaLongitude);

    if (!mounted) return;
    setState(() {
      _declination = declination;
      _qiblaDirection = bearing;
      _distanceToQibla = distance;
      _isLoading = false;
    });
  }

  double _smoothHeading(double current, double target) {
    final delta = _normalizeAngle(target - current);
    final adjustedDelta = delta > 180 ? delta - 360 : delta;
    final smoothed = current + adjustedDelta * _headingSmoothing;
    return _normalizeAngle(smoothed);
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

  double _normalizeAngle(double angle) {
    final normalized = angle % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  double _angleDifference(double a, double b) {
    final diff = (a - b).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }

  void _checkQiblaDirection() {
    final difference = _angleDifference(_smoothedHeading, _qiblaDirection);
    final isQibla = difference < 5; // 5 derece tolerans

    if (isQibla != _isQiblaFound) {
      setState(() {
        _isQiblaFound = isQibla;
      });

      if (isQibla) {
        HapticFeedback.mediumImpact();
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  String _getDirectionText() {
    final loc = AppLocalizations.of(context)!;
    if (_isQiblaFound) {
      return loc.qiblaFound;
    } else {
      final difference = _angleDifference(_qiblaDirection, _smoothedHeading);
      final isRight = _normalizeAngle(_qiblaDirection - _smoothedHeading) < 180;
      if (isRight && difference >= 1) {
        return loc.turnRight;
      } else {
        return loc.turnLeft;
      }
    }
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _magnetometerSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildMessage(String text, {VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onRetry,
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        title: Text(loc.qiblaCompass),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: colors.primary,
        ),
      )
          : _locationFailed
          ? _buildMessage(loc.locationError, onRetry: _calculateQiblaDirection)
          : _sensorMissing
          ? _buildMessage(loc.compassNotAvailable)
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
                          color: colors.surface,
                          border: Border.all(
                            color: colors.surface,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withOpacity(0.15),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),

                      // Yön Göstergeleri
                      ..._buildDirectionMarkers(colors),

                      // Kıble Yönü İşareti: merkezden Kâbe'ye uzanan ibre
                      Transform.rotate(
                        angle: _degreesToRadians(_qiblaDirection - _smoothedHeading),
                        child: SizedBox(
                          width: 300,
                          height: 300,
                          child: Column(
                            children: [
                              const SizedBox(height: 66),
                              const SizedBox(
                                height: 36,
                                child: Text('🕋', style: TextStyle(fontSize: 28)),
                              ),
                              Container(
                                width: 4,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.secondary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Merkez Nokta
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.onSurface,
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
                              color: colors.primary.withOpacity(0.28),
                              border: Border.all(
                                color: colors.primary,
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
                    color: _isQiblaFound ? colors.primary : colors.secondary,
                  ),
                ),

                const SizedBox(height: 20),

                // Mesafe Bilgisi
                Text(
                  loc.distanceToKaaba(_distanceToQibla.toStringAsFixed(0)),
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.onSurface.withOpacity(0.7),
                  ),
                ),

                // Manyetik parazit / kalibrasyon uyarısı
                if (_interference) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      loc.compassCalibrationHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                ],

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
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: colors.onPrimary, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      loc.youAreFacingQibla,
                      style: TextStyle(
                        color: colors.onPrimary,
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

  List<Widget> _buildDirectionMarkers(ColorScheme colors) {
    final directions = [
      {'label': 'N', 'angle': 0},
      {'label': 'E', 'angle': 90},
      {'label': 'S', 'angle': 180},
      {'label': 'W', 'angle': 270},
    ];

    return directions.map((direction) {
      final angle = _degreesToRadians(
          (direction['angle'] as num).toDouble() - _smoothedHeading
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
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: 2,
                  height: 15,
                  color: colors.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }
}
