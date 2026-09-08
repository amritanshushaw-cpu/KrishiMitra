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

  Future<FarmLocation?> fetchCurrentLocation({Duration timeout = const Duration(seconds: 6)}) async {
    try {
      // Fetching real location using IP Geolocation API
      final response = await http.get(Uri.parse('http://ip-api.com/json')).timeout(timeout);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final loc = FarmLocation(
            city: data['city'] ?? 'Unknown',
            region: data['regionName'] ?? 'Unknown',
            country: data['country'] ?? 'Unknown',
            latitude: (data['lat'] as num?)?.toDouble(),
            longitude: (data['lon'] as num?)?.toDouble(),
            zip: data['zip'] ?? '',
          );
          await _cacheLocation(loc);
          return loc;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching actual location: $e');
      }
    }
    
    // Fallback if offline
    final fallback = const FarmLocation(
      city: 'Bardhaman',
      region: 'West Bengal',
      country: 'India',
      latitude: 23.2324,
      longitude: 87.8615,
      zip: '713101',
    );
    await _cacheLocation(fallback);
    return fallback;
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
