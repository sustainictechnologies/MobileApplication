import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

enum AuthState { unauthenticated, authenticated, loading }

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _client = http.Client();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool       get isLoggedIn  => _currentUser != null;

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final uri      = Uri.parse('$kApiBase/auth/login');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Login failed');
    }

    final data   = body['data'] as Map<String, dynamic>;
    _currentUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return _currentUser!;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri      = Uri.parse('$kApiBase/auth/register');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw Exception(body['error'] ?? 'Registration failed');
    }

    final data   = body['data'] as Map<String, dynamic>;
    _currentUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    return _currentUser!;
  }

  Future<void> signOut() async {
    await _client.post(Uri.parse('$kApiBase/auth/logout'));
    _currentUser = null;
  }

  Future<List<RefillRecord>> getRefillHistory() async {
    if (_currentUser == null) return [];

    final uri      = Uri.parse('$kApiBase/refills?userId=${_currentUser!.id}');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load refill history (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list  = body['data'] as List<dynamic>;
    return list.map((e) => RefillRecord.fromJson(e as Map<String, dynamic>)).toList();
  }
}
