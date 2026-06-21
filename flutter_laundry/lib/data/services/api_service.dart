import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../models/order_model.dart';
import '../models/layanan_model.dart';
import '../models/lokasi_model.dart';
import '../models/mitra_laundry_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/utils/storage_service.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // Attach token ke header
  static Future<Options> _authOptions() async {
    final token = await StorageService.getToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ─── AUTH ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String noTelp,
    required String alamat,
    required String username,
    required String password,
    String role = "USER",
  }) async {
    final response = await _dio.post(ApiEndpoints.register, data: {
      'nama': nama,
      'email': email,
      'no_telp': noTelp,
      'alamat': alamat,
      'username': username,
      'password': password,
      'role': role,
    });
    return response.data as Map<String, dynamic>;
  }

  static Future<({String token, UserModel user})> login({
    required String identifier,
    required String password,
  }) async {
    final response = await _dio.post(ApiEndpoints.login, data: {
      'identifier': identifier,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    final token = data['token'] as String;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

    await StorageService.saveToken(token);
    await StorageService.saveUser(user.toJson());

    return (token: token, user: user);
  }

  // ─── LAYANAN ─────────────────────────────────────────────────────────────

  static Future<List<LayananModel>> getLayanan() async {
    final response = await _dio.get(ApiEndpoints.layanan);
    final list = response.data as List;
    return list.map((e) => LayananModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ─── ORDERS ──────────────────────────────────────────────────────────────

  static Future<List<OrderModel>> getOrders() async {
    final opts = await _authOptions();
    final response = await _dio.get(ApiEndpoints.orders, options: opts);
    final list = response.data as List;
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<OrderModel> createOrder({
    required int idLayanan,
    required double beratKg,
    required String alamatPickup,
    required String alamatDelivery,
    required String tanggalPickup,
    required String jamPickup,
    String? catatan,
    String metodePembayaran = 'BAYAR DI TEMPAT',
    String? kodePromo,
  }) async {
    final opts = await _authOptions();
    final response = await _dio.post(ApiEndpoints.orders, options: opts, data: {
      'id_layanan': idLayanan,
      'berat_kg': beratKg,
      'alamat_pickup': alamatPickup,
      'alamat_delivery': alamatDelivery,
      'tanggal_pickup': tanggalPickup,
      'jam_pickup': jamPickup,
      'catatan': catatan,
      'metode_pembayaran': metodePembayaran,
      'kode_promo': kodePromo,
    });
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  static Future<OrderModel> updateOrderStatus({
    required int orderId,
    required String statusOrder,
    String? keterangan,
  }) async {
    final opts = await _authOptions();
    final response = await _dio.patch(
      ApiEndpoints.orderStatus(orderId),
      options: opts,
      data: {'status_order': statusOrder, 'keterangan': keterangan},
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── PROMO ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> checkPromo(String kode) async {
    final opts = await _authOptions();
    final response = await _dio.get(ApiEndpoints.checkPromo(kode), options: opts);
    return response.data as Map<String, dynamic>;
  }

  // ─── TRACKING ────────────────────────────────────────────────────────────

  static Future<OrderModel> getTracking(String kodeOrder) async {
    final response = await _dio.get(ApiEndpoints.tracking(kodeOrder));
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  // ─── KURIR LOKASI (Maps) ─────────────────────────────────────────────────

  /// Kurir mengirim lokasi terbaru ke backend (lat/lng)
  static Future<void> updateKurirLokasi({
    required double latitude,
    required double longitude,
    int? idOrder,
  }) async {
    final opts = await _authOptions();
    await _dio.post(
      ApiEndpoints.kurirLokasi,
      options: opts,
      data: {
        'latitude': latitude,
        'longitude': longitude,
        'id_order': idOrder,
      },
    );
  }

  /// User membaca lokasi kurir berdasarkan id_order (untuk polling di tracking screen)
  static Future<LokasiModel?> getKurirLokasiByOrder(int idOrder) async {
    try {
      final response = await _dio.get(ApiEndpoints.kurirLokasiByOrder(idOrder));
      return LokasiModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Ambil lokasi kurir langsung by id_kurir
  static Future<LokasiModel?> getKurirLokasiById(int idKurir) async {
    try {
      final response = await _dio.get(ApiEndpoints.kurirLokasiById(idKurir));
      return LokasiModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  // ─── LBS — MITRA LAUNDRY ─────────────────────────────────────────────────

  /// Ambil semua data mitra laundry dari backend
  static Future<List<MitraLaundryModel>> getMitraLaundry() async {
    final response = await _dio.get(ApiEndpoints.mitraLaundry);
    final list = response.data as List;
    return list
        .map((e) => MitraLaundryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── ADMIN STATS ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAdminRevenueStats() async {
    final opts = await _authOptions();
    final response = await _dio.get(ApiEndpoints.adminRevenueStats, options: opts);
    return response.data as Map<String, dynamic>;
  }
}
