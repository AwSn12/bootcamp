class LayananModel {
  final int idLayanan;
  final String namaLayanan;
  final String deskripsi;
  final double hargaPerKg;
  final int estimasiHari;
  final String? fotoLayanan;

  LayananModel({
    required this.idLayanan,
    required this.namaLayanan,
    required this.deskripsi,
    required this.hargaPerKg,
    required this.estimasiHari,
    this.fotoLayanan,
  });

  factory LayananModel.fromJson(Map<String, dynamic> json) {
    return LayananModel(
      idLayanan: json['id_layanan'] as int,
      namaLayanan: json['nama_layanan'] as String,
      deskripsi: json['deskripsi'] as String,
      hargaPerKg: (json['harga_per_kg'] as num).toDouble(),
      estimasiHari: json['estimasi_hari'] as int,
      fotoLayanan: json['foto_layanan'] as String?,
    );
  }
}
