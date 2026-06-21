import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/models/lokasi_model.dart';
import '../data/services/api_service.dart';

class MapsProvider extends ChangeNotifier {
  LokasiModel? _kurirLokasi;
  bool _isLoading = false;
  String? _error;
  Timer? _pollingTimer;

  LokasiModel? get kurirLokasi => _kurirLokasi;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Koordinat kurir dari backend (null jika belum ada data)
  double? get kurirLat => _kurirLokasi?.latitude;
  double? get kurirLng => _kurirLokasi?.longitude;

  /// Mulai polling lokasi kurir setiap [intervalSeconds] detik
  void startPolling(int orderId, {int intervalSeconds = 5}) {
    _fetchKurirLokasi(orderId); // fetch langsung
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _fetchKurirLokasi(orderId),
    );
  }

  /// Hentikan polling (panggil di dispose screen)
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchKurirLokasi(int orderId) async {
    try {
      final lokasi = await ApiService.getKurirLokasiByOrder(orderId);
      _kurirLokasi = lokasi;
      _error = null;
    } catch (e) {
      // Tidak tampilkan error polling — cukup diam jika gagal
    }
    notifyListeners();
  }

  /// Kurir mengirim lokasi ke backend
  Future<bool> sendKurirLokasi({
    required double latitude,
    required double longitude,
    int? idOrder,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await ApiService.updateKurirLokasi(
        latitude: latitude,
        longitude: longitude,
        idOrder: idOrder,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Gagal mengirim lokasi: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
