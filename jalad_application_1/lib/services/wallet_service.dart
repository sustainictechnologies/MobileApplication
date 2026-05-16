import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import 'auth_service.dart';

class InsufficientBalanceException implements Exception {
  const InsufficientBalanceException();

  @override
  String toString() => 'Insufficient wallet balance.';
}

class WalletService {
  WalletService._();
  static final WalletService instance = WalletService._();

  final _client = http.Client();

  Future<double> topUp(double amount) => _walletOp('topup', amount);
  Future<double> deduct(double amount) => _walletOp('deduct', amount);

  Future<double> _walletOp(String operation, double amount) async {
    final auth   = AuthService.instance;
    final userId = auth.currentUser?.id;
    if (userId == null) throw Exception('Not logged in.');

    final response = await _client.patch(
      Uri.parse('$kApiBase/users/$userId/wallet'),
      headers: {
        'Content-Type':  'application/json',
        'Authorization': 'Bearer ${auth.token}',
      },
      body: jsonEncode({'operation': operation, 'amount': amount}),
    );

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 422) throw const InsufficientBalanceException();
    if (response.statusCode != 200) {
      throw Exception(body['error'] ?? 'Wallet operation failed.');
    }

    final newBalance = (body['data']['wallet_balance'] as num).toDouble();
    await auth.updateLocalBalance(newBalance);
    return newBalance;
  }
}