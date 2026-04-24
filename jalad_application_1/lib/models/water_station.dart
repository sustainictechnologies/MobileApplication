class WaterStation {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final bool isOnline;
  final double pricePerLitre;
  final double availableCapacityLitres;
  final double rating;
  final int reviewCount;
  final WaterQuality waterQuality;
  final List<String> amenities;

  const WaterStation({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.isOnline,
    required this.pricePerLitre,
    required this.availableCapacityLitres,
    required this.rating,
    required this.reviewCount,
    required this.waterQuality,
    this.amenities = const [],
  });

  factory WaterStation.fromJson(Map<String, dynamic> json) {
    return WaterStation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      isOnline: json['is_online'] as bool,
      pricePerLitre: (json['price_per_litre'] as num).toDouble(),
      availableCapacityLitres: (json['available_capacity_litres'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['review_count'] as int,
      waterQuality: WaterQuality.fromJson(json['water_quality'] as Map<String, dynamic>),
      amenities: List<String>.from(json['amenities'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'distance_km': distanceKm,
        'is_online': isOnline,
        'price_per_litre': pricePerLitre,
        'available_capacity_litres': availableCapacityLitres,
        'rating': rating,
        'review_count': reviewCount,
        'water_quality': waterQuality.toJson(),
        'amenities': amenities,
      };

  WaterStation copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    double? distanceKm,
    bool? isOnline,
    double? pricePerLitre,
    double? availableCapacityLitres,
    double? rating,
    int? reviewCount,
    WaterQuality? waterQuality,
    List<String>? amenities,
  }) {
    return WaterStation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      isOnline: isOnline ?? this.isOnline,
      pricePerLitre: pricePerLitre ?? this.pricePerLitre,
      availableCapacityLitres: availableCapacityLitres ?? this.availableCapacityLitres,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      waterQuality: waterQuality ?? this.waterQuality,
      amenities: amenities ?? this.amenities,
    );
  }
}

class WaterQuality {
  final String label;
  final double phLevel;
  final double tdsLevel;
  final double turbidity;   // NTU
  final double temperature; // °C
  final DateTime lastTestedAt;

  const WaterQuality({
    required this.label,
    required this.phLevel,
    required this.tdsLevel,
    required this.turbidity,
    required this.temperature,
    required this.lastTestedAt,
  });

  factory WaterQuality.fromJson(Map<String, dynamic> json) {
    return WaterQuality(
      label:       json['label'] as String,
      phLevel:     (json['ph_level'] as num).toDouble(),
      tdsLevel:    (json['tds_level'] as num).toDouble(),
      turbidity:   (json['turbidity'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      lastTestedAt: DateTime.parse(json['last_tested_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'label':        label,
        'ph_level':     phLevel,
        'tds_level':    tdsLevel,
        'turbidity':    turbidity,
        'temperature':  temperature,
        'last_tested_at': lastTestedAt.toIso8601String(),
      };
}
