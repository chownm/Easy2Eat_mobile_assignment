import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/map/Response/geoapify_response.dart';
import 'map_retrofit_client.dart';

class RouteInfo {
  final double distanceKm;
  final double durationMinutes;
  final List<LatLng> routePoints;
  const RouteInfo({
    required this.distanceKm,
    required this.durationMinutes,
    this.routePoints = const [],
  });
}

class MapApiService {
  static final MapRetrofitClient _client = MapRetrofitClient(Dio());

  /// Read the Geoapify API Key from .env securely
  static String get geoapifyApiKey => dotenv.env['GEOAPIFY_API_KEY'] ?? '';

  /// Address Autocomplete Search
  static Future<List<String>> searchAddress(String query) async {
    if (query.trim().isEmpty || geoapifyApiKey.isEmpty) return [];

    try {
      final GeoapifyResponse response = await _client.searchAddress(query, geoapifyApiKey);
      final features = response.features ?? [];
      return features
          .map((f) => f.properties?.formatted ?? '')
          .where((address) => address.isNotEmpty)
          .toList();
    } catch (e) {
      if (kDebugMode) print('searchAddress error: $e');
      return [];
    }
  }

  /// Reverse Geocoding (Latitude, Longitude -> Formatted Address)
  static Future<String?> getAddressFromCoordinates(double lat, double lng) async {
    if (geoapifyApiKey.isEmpty) return null;

    try {
      final GeoapifyResponse response = await _client.reverseGeocode(lat, lng, geoapifyApiKey);
      final features = response.features ?? [];
      if (features.isNotEmpty) {
        return features.first.properties?.formatted;
      }
    } catch (e) {
      if (kDebugMode) print('getAddressFromCoordinates error: $e');
      return null;
    }
    return null;
  }

  /// Helper to recursively extract LatLng points from GeoJSON coordinates
  static void _extractLatLngs(dynamic item, List<LatLng> result) {
    if (item is List) {
      if (item.length >= 2 && item[0] is num && item[1] is num) {
        // GeoJSON is [longitude, latitude] -> LatLng(latitude, longitude)
        final double lon = (item[0] as num).toDouble();
        final double lat = (item[1] as num).toDouble();
        result.add(LatLng(lat, lon));
      } else {
        for (var element in item) {
          _extractLatLngs(element, result);
        }
      }
    }
  }

  /// Get Delivery Route Details (Distance, Estimated Duration, and Turn-by-Turn Road Polylines)
  static Future<RouteInfo?> getDeliveryRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String mode = 'drive',
  }) async {
    if (geoapifyApiKey.isEmpty) return null;

    try {
      final waypoints = '$startLat,$startLng|$endLat,$endLng';
      final GeoapifyResponse response = await _client.getRouting(waypoints, mode, geoapifyApiKey);
      final features = response.features ?? [];

      if (features.isNotEmpty) {
        final props = features.first.properties;
        final distanceMeters = props?.distance ?? 0.0;
        final durationSeconds = props?.time ?? 0.0;

        // Extract turn-by-turn road geometry coordinates recursively
        final geometry = features.first.geometry;
        final rawCoords = geometry?.coordinates;

        List<LatLng> roadPoints = [];
        if (rawCoords != null) {
          _extractLatLngs(rawCoords, roadPoints);
        }

        if (kDebugMode) {
          print('Extracted ${roadPoints.length} road polyline points from Geoapify!');
        }

        if (roadPoints.isEmpty) {
          roadPoints = [LatLng(startLat, startLng), LatLng(endLat, endLng)];
        }

        return RouteInfo(
          distanceKm: distanceMeters / 1000.0,
          durationMinutes: durationSeconds / 60.0,
          routePoints: roadPoints, // Turn-by-turn road waypoints!
        );
      }
    } catch (e) {
      if (kDebugMode) print('getDeliveryRoute error: $e');
      return null;
    }
    return null;
  }
}
