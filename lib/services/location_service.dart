import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Structured model representing the farmer's geolocated farm plot.
class FarmLocation {
  final String city;
  final String region;
  final String country;
  final double? latitude;
  final double? longitude;
  final String zip;

  const FarmLocation({
    required this.city,
    required this.region,
    required this.country,
    this.latitude,
    this.longitude,
    this.zip = '',
  });

  String get formattedPlotLocation {
    if (city.isNotEmpty && region.isNotEmpty) {
      return '$city, $region';
    } else if (city.isNotEmpty) {
      return city;
    } else if (region.isNotEmpty) {
      return region;
    }
    return 'Bardhaman, West Bengal';
  }

  String get coordinatesDisplay {
    if (latitude != null && longitude != null) {
      final latDir = latitude! >= 0 ? 'N' : 'S';
      final lonDir = longitude! >= 0 ? 'E' : 'W';
      return '${latitude!.abs().toStringAsFixed(4)}° $latDir, ${longitude!.abs().toStringAsFixed(4)}° $lonDir';
    }
    return '';
  }
}

/// Service to automatically detect and cache the farmer's location.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  static const String prefKeyLocation = 'farmer_location';
  static const String prefKeyLat = 'farmer_lat';
  static const String prefKeyLon = 'farmer_lon';
  static const String defaultLocation = 'Bardhaman, West Bengal';

  /// Auto-fetches current location using secure high-speed endpoints with fallbacks.
  Future<FarmLocation?> fetchCurrentLocation({Duration timeout = const Duration(seconds: 4)}) async {
    // 1. Primary: FreeIPAPI (HTTPS)
    try {
      final response = await http.get(
        Uri.parse('https://freeipapi.com/api/json'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final city = data['cityName']?.toString() ?? '';
        final region = data['regionName']?.toString() ?? '';
        final country = data['countryName']?.toString() ?? 'India';
        final double? lat = (data['latitude'] is num) ? (data['latitude'] as num).toDouble() : null;
        final double? lon = (data['longitude'] is num) ? (data['longitude'] as num).toDouble() : null;
        final zip = data['zipCode']?.toString() ?? '';

        if (city.isNotEmpty || region.isNotEmpty) {
          final loc = FarmLocation(
            city: city,
            region: region,
            country: country,
            latitude: lat,
            longitude: lon,
            zip: zip,
          );
          await _cacheLocation(loc);
          return loc;
        }
      }
    } catch (e) {
      debugPrint('FreeIPAPI lookup note: $e. Trying fallback endpoint...');
    }

    // 2. Secondary Fallback: ip-api
    try {
      final response = await http.get(
        Uri.parse('http://ip-api.com/json'),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final city = data['city']?.toString() ?? '';
          final region = data['regionName']?.toString() ?? '';
          final country = data['country']?.toString() ?? 'India';
          final double? lat = (data['lat'] is num) ? (data['lat'] as num).toDouble() : null;
          final double? lon = (data['lon'] is num) ? (data['lon'] as num).toDouble() : null;
          final zip = data['zip']?.toString() ?? '';

          final loc = FarmLocation(
            city: city,
            region: region,
            country: country,
            latitude: lat,
            longitude: lon,
            zip: zip,
          );
          await _cacheLocation(loc);
          return loc;
        }
      }
    } catch (e) {
      debugPrint('Fallback geolocation note: $e');
    }

    return null;
  }

  Future<void> _cacheLocation(FarmLocation location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefKeyLocation, location.formattedPlotLocation);
      if (location.latitude != null) await prefs.setDouble(prefKeyLat, location.latitude!);
      if (location.longitude != null) await prefs.setDouble(prefKeyLon, location.longitude!);
    } catch (_) {}
  }

  Future<String> getCachedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(prefKeyLocation) ?? defaultLocation;
    } catch (_) {
      return defaultLocation;
    }
  }
}
