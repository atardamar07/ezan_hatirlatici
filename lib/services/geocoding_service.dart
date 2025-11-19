import 'package:flutter/foundation.dart' show debugPrint;
import 'package:geocoding/geocoding.dart';

class GeocodingService {
  /// Search for city-like locations using the geocoding package.
  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    try {
      final locations = await locationFromAddress(query);
      final results = <Map<String, dynamic>>[];

      for (final location in locations) {
        final placemarks =
        await placemarkFromCoordinates(location.latitude, location.longitude);
        final placemark = placemarks.isNotEmpty ? placemarks.first : null;

        final cityName = placemark?.locality?.isNotEmpty == true
            ? placemark!.locality
            : placemark?.administrativeArea?.isNotEmpty == true
            ? placemark!.administrativeArea
            : query;

        results.add({
          'name': cityName ?? query,
          'country': placemark?.country ?? '',
          'latitude': location.latitude,
          'longitude': location.longitude,
        });
      }

      return results;
    } catch (e) {
      debugPrint('Error searching cities: $e');
      rethrow;
    }
  }
}