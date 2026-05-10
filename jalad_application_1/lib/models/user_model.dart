class UserModel {
  final String id;
  final String name;
  final String email;
  final String accountType;
  final String? qrCode;
  final String? avatarUrl;
  final double totalLitresSaved;
  final int totalRefills;
  final double walletBalance;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.accountType = 'user',
    this.qrCode,
    this.avatarUrl,
    required this.totalLitresSaved,
    required this.totalRefills,
    required this.walletBalance,
    required this.createdAt,
  });

  double get plasticBottlesSaved => totalLitresSaved / 0.5;

  double get co2SavedKg => plasticBottlesSaved * 0.082;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      accountType: (json['account_type'] as String?) ?? 'user',
      qrCode: json['qr_code'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      totalLitresSaved: (json['total_litres_saved'] as num).toDouble(),
      totalRefills: json['total_refills'] as int,
      walletBalance: (json['wallet_balance'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        if (qrCode != null) 'qr_code': qrCode,
        'avatar_url': avatarUrl,
        'total_litres_saved': totalLitresSaved,
        'total_refills': totalRefills,
        'wallet_balance': walletBalance,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? qrCode,
    String? avatarUrl,
    double? totalLitresSaved,
    int? totalRefills,
    double? walletBalance,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      qrCode: qrCode ?? this.qrCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalLitresSaved: totalLitresSaved ?? this.totalLitresSaved,
      totalRefills: totalRefills ?? this.totalRefills,
      walletBalance: walletBalance ?? this.walletBalance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RefillRecord {
  final String id;
  final String stationId;
  final String stationName;
  final double litresFilled;
  final double amountPaid;
  final DateTime refillAt;

  const RefillRecord({
    required this.id,
    required this.stationId,
    required this.stationName,
    required this.litresFilled,
    required this.amountPaid,
    required this.refillAt,
  });

  factory RefillRecord.fromJson(Map<String, dynamic> json) {
    return RefillRecord(
      id: json['id'] as String,
      stationId: json['station_id'] as String,
      stationName: json['station_name'] as String,
      litresFilled: (json['litres_filled'] as num).toDouble(),
      amountPaid: (json['amount_paid'] as num).toDouble(),
      refillAt: DateTime.parse(json['refill_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'station_id': stationId,
        'station_name': stationName,
        'litres_filled': litresFilled,
        'amount_paid': amountPaid,
        'refill_at': refillAt.toIso8601String(),
      };
}
