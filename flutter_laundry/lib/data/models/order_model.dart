import 'layanan_model.dart';

class TrackingModel {
  final int idTracking;
  final int idOrder;
  final String statusTracking;
  final DateTime waktuUpdate;
  final String? keterangan;

  TrackingModel({
    required this.idTracking,
    required this.idOrder,
    required this.statusTracking,
    required this.waktuUpdate,
    this.keterangan,
  });

  factory TrackingModel.fromJson(Map<String, dynamic> json) {
    return TrackingModel(
      idTracking: json['id_tracking'] as int,
      idOrder: json['id_order'] as int,
      statusTracking: json['status_tracking'] as String,
      waktuUpdate: DateTime.parse(json['waktu_update'] as String),
      keterangan: json['keterangan'] as String?,
    );
  }
}

class OrderModel {
  final int idOrder;
  final int idUser;
  final int idLayanan;
  final int? idKurir;
  final String kodeOrder;
  final double beratKg;
  final double subtotal;
  final double ongkir;
  final double totalBayar;
  final String alamatPickup;
  final String alamatDelivery;
  final DateTime tanggalPickup;
  final String jamPickup;
  final String? catatan;
  final String statusOrder;
  final DateTime createdAt;
  final LayananModel? layanan;
  final List<TrackingModel> tracking;

  OrderModel({
    required this.idOrder,
    required this.idUser,
    required this.idLayanan,
    this.idKurir,
    required this.kodeOrder,
    required this.beratKg,
    required this.subtotal,
    required this.ongkir,
    required this.totalBayar,
    required this.alamatPickup,
    required this.alamatDelivery,
    required this.tanggalPickup,
    required this.jamPickup,
    this.catatan,
    required this.statusOrder,
    required this.createdAt,
    this.layanan,
    this.tracking = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      idOrder: json['id_order'] as int,
      idUser: json['id_user'] as int,
      idLayanan: json['id_layanan'] as int,
      idKurir: json['id_kurir'] as int?,
      kodeOrder: json['kode_order'] as String,
      beratKg: (json['berat_kg'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
      ongkir: (json['ongkir'] as num).toDouble(),
      totalBayar: (json['total_bayar'] as num).toDouble(),
      alamatPickup: json['alamat_pickup'] as String,
      alamatDelivery: json['alamat_delivery'] as String,
      tanggalPickup: DateTime.parse(json['tanggal_pickup'] as String),
      jamPickup: json['jam_pickup'] as String,
      catatan: json['catatan'] as String?,
      statusOrder: json['status_order'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      layanan: json['layanan'] != null
          ? LayananModel.fromJson(json['layanan'] as Map<String, dynamic>)
          : null,
      tracking: json['tracking'] != null
          ? (json['tracking'] as List)
              .map((t) => TrackingModel.fromJson(t as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  String get statusLabel {
    switch (statusOrder) {
      case 'menunggu pickup': return 'Menunggu Pickup';
      case 'dijemput kurir': return 'Dijemput Kurir';
      case 'sedang dicuci': return 'Sedang Dicuci';
      case 'sedang disetrika': return 'Sedang Disetrika';
      case 'selesai': return 'Selesai';
      case 'diantar': return 'Diantar';
      case 'selesai diterima': return 'Selesai Diterima';
      default: return statusOrder;
    }
  }
}
