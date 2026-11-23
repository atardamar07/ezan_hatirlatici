import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Konum izni yönetimi
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      try {
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        return true;
      } catch (e) {
        debugPrint('Web location permission denied: $e');
        return false;
      }
    } else {
      // Konum kapalıysa da devam: getCurrentPosition Google'ın "konumu aç" penceresini gösterir
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }

      if (permission == LocationPermission.deniedForever) return false;

      return true;
    }
  }

  /// Konumu al. Namaz vakti ve kıble için şehir düzeyi doğruluk yeterli;
  /// GPS'i beklemek kapalı alanda dakikalarca sürebileceği için süre sınırı var.
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await requestPermission();
      if (!hasPermission) return null;

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 15),
          ),
        );
      } on TimeoutException {
        return await Geolocator.getLastKnownPosition();
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// MAHALLE + İLÇE + ŞEHİR döndürür
  Future<String?> getFullAddress(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) return null;

      Placemark place = placemarks.first;

      final neighborhood = place.subLocality;          // Mahalle
      final district = place.subAdministrativeArea;    // İlçe
      final city = place.administrativeArea;           // Şehir

      // Boş gelmeyenleri sırayla birleştir
      final parts = <String>[
        if (neighborhood != null && neighborhood.isNotEmpty) neighborhood,
        if (district != null && district.isNotEmpty) district,
        if (city != null && city.isNotEmpty) city,
      ];

      if (parts.isEmpty) return null;

      return parts.join(", "); // Örn: "Kızılay, Çankaya, Ankara"
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }

  /// Şehir arama (city selection screen için)
  Future<Map<String, double>?> getCityCoordinates(String cityName) async {
    try {
      List<Location> locations = await locationFromAddress(cityName);
      if (locations.isNotEmpty) {
        return {
          'latitude': locations[0].latitude,
          'longitude': locations[0].longitude,
        };
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return null;
    }
  }
}
