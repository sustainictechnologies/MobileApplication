import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/water_station.dart';
import 'auth_service.dart';

class WaterStationService {
  WaterStationService._();
  static final WaterStationService instance = WaterStationService._();

  final _client = http.Client();

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (AuthService.instance.token != null)
      'Authorization': 'Bearer ${AuthService.instance.token}',
  };

  Future<List<WaterStation>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radiusKm = AppConstants.defaultSearchRadiusKm,
  }) async {
    final uri = Uri.parse('$kApiBase/stations').replace(queryParameters: {
      'lat': latitude.toString(),
      'lng': longitude.toString(),
      'radius': radiusKm.toString(),
    });

    final response = await _client.get(uri, headers: _authHeaders);

    if (response.statusCode != 200) {
      throw Exception('Failed to load stations (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>;
    return list
        .map((e) => WaterStation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WaterStation?> getStationById(String id) async {
    final uri = Uri.parse('$kApiBase/stations/$id');
    final response = await _client.get(uri, headers: _authHeaders);

    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw Exception('Failed to load station $id (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return WaterStation.fromJson(body['data'] as Map<String, dynamic>);
  }
}