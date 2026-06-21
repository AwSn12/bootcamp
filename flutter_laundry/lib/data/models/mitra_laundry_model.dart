class MitraLaundryModel {
  final int id;
  final String namaLaundry;
  final String alamat;
  final double latitude;
  final double longitude;
  final double hargaPerKg;
  final bool statusAktif;
  // Field non-database — diisi setelah perhitungan Haversine
  double? jarakKm;

  MitraLaundryModel({
    required this.id,
    required this.namaLaundry,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    required this.hargaPerKg,
    required this.statusAktif,
    this.jarakKm,
  });

  factory MitraLaundryModel.fromJson(Map<String, dynamic> json) {
    return MitraLaundryModel(
      id: json['id'] as int,
      namaLaundry: json['nama_laundry'] as String,
      alamat: json['alamat'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      hargaPerKg: (json['harga_per_kg'] as num).toDouble(),
      statusAktif: json['status_aktif'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama_laundry': namaLaundry,
        'alamat': alamat,
        'latitude': latitude,
        'longitude': longitude,
        'harga_per_kg': hargaPerKg,
        'status_aktif': statusAktif,
      };

  /// Format harga sebagai string Rupiah
  String get hargaFormatted {
    final harga = hargaPerKg.toInt();
    return 'Rp ${harga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}/kg';
  }

  /// Format jarak sebagai string km
  String get jarakFormatted {
    if (jarakKm == null) return '-';
    if (jarakKm! < 1.0) {
      return '${(jarakKm! * 1000).toStringAsFixed(0)} m';
    }
    return '${jarakKm!.toStringAsFixed(2)} km';
  }
}
