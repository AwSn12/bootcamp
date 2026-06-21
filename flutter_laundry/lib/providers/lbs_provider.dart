import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../data/models/mitra_laundry_model.dart';
import '../data/services/api_service.dart';
import '../core/utils/haversine_util.dart';

class LbsProvider extends ChangeNotifier {
  List<MitraLaundryModel> _mitraList = [];
  List<MitraLaundryModel> _mitraSorted = [];
  bool _isLoading = false;
  String? _error;

  // Lokasi user
  double? _userLat;
  double? _userLng;
  String _statusGps = 'Belum mendapatkan lokasi';
  bool _isGettingLocation = false;

  // Getters
  List<MitraLaundryModel> get mitraList => _mitraList;
  List<MitraLaundryModel> get mitraSorted => _mitraSorted;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get userLat => _userLat;
  double? get userLng => _userLng;
  String get statusGps => _statusGps;
  bool get isGettingLocation => _isGettingLocation;
  bool get hasLocation => _userLat != null && _userLng != null;

  /// Inisialisasi: fetch lokasi user + fetch mitra laundry dari API
  Future<void> init() async {
    await Future.wait([
      _fetchMitraLaundry(),
      getUserLocation(),
    ]);
  }

  /// Fetch daftar mitra laundry dari backend
  Future<void> _fetchMitraLaundry() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final list = await ApiService.getMitraLaundry();
      _mitraList = list;
      _hitungDanSort();
    } catch (e) {
      _error = 'Gagal memuat data laundry: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ambil lokasi GPS user
  Future<void> getUserLocation() async {
    _isGettingLocation = true;
    _statusGps = 'Mendapatkan lokasi...';
    notifyListeners();

    try {
      // Cek service GPS aktif
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _statusGps = 'GPS tidak aktif. Aktifkan GPS di pengaturan.';
        _isGettingLocation = false;
        notifyListeners();
        return;
      }

      // Cek permission GPS
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _statusGps = 'Izin lokasi ditolak.';
          _isGettingLocation = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _statusGps = 'Izin lokasi ditolak permanen. Buka pengaturan aplikasi.';
        _isGettingLocation = false;
        notifyListeners();
        return;
      }

      // Ambil posisi
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      _userLat = position.latitude;
      _userLng = position.longitude;
      _statusGps = 'Lokasi ditemukan ✓';
      _hitungDanSort();
    } catch (e) {
      _statusGps = 'Error GPS: ${e.toString()}';
    } finally {
      _isGettingLocation = false;
      notifyListeners();
    }
  }

  /// Hitung jarak Haversine untuk setiap mitra dan sort dari terdekat ke terjauh
  void _hitungDanSort() {
    if (_userLat == null || _userLng == null) {
      _mitraSorted = List.from(_mitraList);
      return;
    }

    for (final mitra in _mitraList) {
      mitra.jarakKm = HaversineUtil.hitungJarak(
        lat1: _userLat!,
        lon1: _userLng!,
        lat2: mitra.latitude,
        lon2: mitra.longitude,
      );
    }

    _mitraSorted = List.from(_mitraList)
      ..sort((a, b) => (a.jarakKm ?? double.infinity)
          .compareTo(b.jarakKm ?? double.infinity));

    notifyListeners();
  }

  /// Hitung detail Haversine untuk satu mitra (untuk panel debug jurnal)
  Map<String, dynamic>? detailHaversine(MitraLaundryModel mitra) {
    if (_userLat == null || _userLng == null) return null;
    return HaversineUtil.detailPerhitungan(
      lat1: _userLat!,
      lon1: _userLng!,
      lat2: mitra.latitude,
      lon2: mitra.longitude,
    );
  }

  /// Refresh: ambil ulang lokasi & data mitra
  Future<void> refresh() async {
    await init();
  }
}
