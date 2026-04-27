import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _tokenKey = 'auth_token';
  static const _userKey  = 'auth_user';

  final _client = http.Client();

  UserModel? _currentUser;
  String?    _token;

  UserModel? get currentUser => _currentUser;
  String?    get token       => _token;
  bool       get isLoggedIn  => _currentUser != null && _token != null;

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  // ─── Session restore ────────────────────────────────────────────────────────

  /// True if user data is stored on device (even if token has expired).
  /// Used by the splash screen to decide: onboarding vs login vs biometric.
  Future<bool> hasStoredUser() async {
    final v = await _storage.read(key: _userKey);
    return v != null;
  }

  /// Call once at app start. Returns true if a valid, non-expired session exists.
  Future<bool> init() async {
    try {
      final storedToken = await _storage.read(key: _tokenKey);
      final storedUser  = await _storage.read(key: _userKey);
      if (storedToken == null || storedUser == null) return false;
      if (_isExpired(storedToken)) return false;

      _token       = storedToken;
      _currentUser = UserModel.fromJson(
        jsonDecode(storedUser) as Map<String, dynamic>,
      );
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Decodes the JWT payload locally to check the exp claim.
  /// No signature verification — only the server verifies signatures.
  bool _isExpired(String token) {
    try {
      final parts   = token.split('.');
      if (parts.length != 3) return true;
      final padding = parts[1].length % 4;
      final padded  = padding > 0 ? parts[1] + ('=' * (4 - padding)) : parts[1];
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(padded)),
      ) as Map<String, dynamic>;
      final exp = payload['exp'] as int?;
      if (exp == null) return true;
      return DateTime.now().isAfter(
        DateTime.fromMillisecondsSinceEpoch(exp * 1000),
      );
    } catch (_) {
      return true;
    }
  }

  Future<void> _persist(String token, UserModel user) async {
    await Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _userKey,  value: jsonEncode(user.toJson())),
    ]);
    _token       = token;
    _currentUser = user;
    notifyListeners();
  }

  // ─── Auth actions ────────────────────────────────────────────────────────────

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$kApiBase/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Login failed');
    }

    final data = body['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _persist(data['token'] as String, user);
    return user;
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String accountType = 'user',
  }) async {
    final response = await _client.post(
      Uri.parse('$kApiBase/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password, 'account_type': accountType}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 201) {
      throw Exception(body['error'] ?? 'Registration failed');
    }

    final data = body['data'] as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    await _persist(data['token'] as String, user);
    return user;
  }

  /// Exchanges the current valid token for a fresh 7-day token.
  /// Called after biometric authentication succeeds.
  Future<void> refreshToken() async {
    if (_token == null) throw Exception('No token to refresh');

    final response = await _client.post(
      Uri.parse('$kApiBase/auth/refresh'),
      headers: _authHeaders,
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Token refresh failed');
    }

    final newToken = (body['data'] as Map<String, dynamic>)['token'] as String;
    await _storage.write(key: _tokenKey, value: newToken);
    _token = newToken;
    notifyListeners();
  }

  Future<void> signOut() async {
    // Best-effort logout call — don't fail if offline
    if (_token != null) {
      try {
        await _client.post(
          Uri.parse('$kApiBase/auth/logout'),
          headers: _authHeaders,
        );
      } catch (_) {}
    }
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userKey),
    ]);
    _token       = null;
    _currentUser = null;
    notifyListeners();
  }

  // ─── Data ────────────────────────────────────────────────────────────────────

  Future<List<RefillRecord>> getRefillHistory() async {
    if (_currentUser == null) return [];

    final response = await _client.get(
      Uri.parse('$kApiBase/refills?userId=${_currentUser!.id}'),
      headers: _authHeaders,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load refill history (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final list = body['data'] as List<dynamic>;
    return list
        .map((e) => RefillRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}