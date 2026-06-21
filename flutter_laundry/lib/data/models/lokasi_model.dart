class LokasiModel {
  final int idKurir;
  final double latitude;
  final double longitude;
  final int? idOrder;
  final DateTime updatedAt;

  LokasiModel({
    required this.idKurir,
    required this.latitude,
    required this.longitude,
    this.idOrder,
    required this.updatedAt,
  });

  factory LokasiModel.fromJson(Map<String, dynamic> json) {
    return LokasiModel(
      idKurir: json['id_kurir'] as int,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      idOrder: json['id_order'] as int?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_kurir': idKurir,
        'latitude': latitude,
        'longitude': longitude,
        'id_order': idOrder,
        'updated_at': updatedAt.toIso8601String(),
      };
}
