import 'dart:math';

/// Utilitas perhitungan jarak menggunakan Rumus Haversine.
///
/// Rumus Haversine menghitung jarak terpendek antara dua titik
/// di permukaan bola (bumi) menggunakan koordinat lintang dan bujur.
///
/// Formula:
///   a = sin²(Δlat/2) + cos(lat1) * cos(lat2) * sin²(Δlong/2)
///   c = 2 * atan2(√a, √(1−a))
///   d = R * c
///
/// dimana R = jari-jari bumi = 6371 km
class HaversineUtil {
  /// Jari-jari bumi dalam kilometer
  static const double _earthRadiusKm = 6371.0;

  /// Menghitung jarak antara dua koordinat GPS menggunakan Rumus Haversine.
  ///
  /// [lat1] Latitude titik pertama (derajat)
  /// [lon1] Longitude titik pertama (derajat)
  /// [lat2] Latitude titik kedua (derajat)
  /// [lon2] Longitude titik kedua (derajat)
  ///
  /// Returns: Jarak dalam kilometer (km)
  static double hitungJarak({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    // Konversi derajat ke radian
    final dLat = _derajatKeRadian(lat2 - lat1);
    final dLon = _derajatKeRadian(lon2 - lon1);

    final lat1Rad = _derajatKeRadian(lat1);
    final lat2Rad = _derajatKeRadian(lat2);

    // Haversine formula
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  /// Konversi derajat ke radian
  static double _derajatKeRadian(double derajat) {
    return derajat * (pi / 180.0);
  }

  /// Format jarak ke string yang mudah dibaca
  static String formatJarak(double jarakKm) {
    if (jarakKm < 1.0) {
      return '${(jarakKm * 1000).toStringAsFixed(0)} m';
    }
    return '${jarakKm.toStringAsFixed(2)} km';
  }

  /// Data detail perhitungan Haversine untuk keperluan jurnal / debug
  static Map<String, dynamic> detailPerhitungan({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    final dLat = _derajatKeRadian(lat2 - lat1);
    final dLon = _derajatKeRadian(lon2 - lon1);
    final lat1Rad = _derajatKeRadian(lat1);
    final lat2Rad = _derajatKeRadian(lat2);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final d = _earthRadiusKm * c;

    return {
      'lat_user': lat1,
      'lon_user': lon1,
      'lat_laundry': lat2,
      'lon_laundry': lon2,
      'delta_lat_deg': lat2 - lat1,
      'delta_lon_deg': lon2 - lon1,
      'delta_lat_rad': dLat,
      'delta_lon_rad': dLon,
      'nilai_a': a,
      'nilai_c': c,
      'jarak_km': d,
      'jarak_m': d * 1000,
      'R': _earthRadiusKm,
    };
  }
}
