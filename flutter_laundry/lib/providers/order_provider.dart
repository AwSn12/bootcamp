import 'package:flutter/foundation.dart';
import '../data/models/order_model.dart';
import '../data/models/layanan_model.dart';
import '../data/services/api_service.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  List<LayananModel> _layanan = [];
  bool _isLoading = false;
  String? _error;
  OrderModel? _trackingResult;

  List<OrderModel> get orders => _orders;
  List<LayananModel> get layanan => _layanan;
  bool get isLoading => _isLoading;
  String? get error => _error;
  OrderModel? get trackingResult => _trackingResult;

  Future<void> fetchLayanan() async {
    try {
      _layanan = await ApiService.getLayanan();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      _orders = await ApiService.getOrders();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> createOrder({
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
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final order = await ApiService.createOrder(
        idLayanan: idLayanan,
        beratKg: beratKg,
        alamatPickup: alamatPickup,
        alamatDelivery: alamatDelivery,
        tanggalPickup: tanggalPickup,
        jamPickup: jamPickup,
        catatan: catatan,
        metodePembayaran: metodePembayaran,
        kodePromo: kodePromo,
      );
      _orders.insert(0, order);
      _isLoading = false;
      notifyListeners();
      return order.kodeOrder;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchTracking(String kode) async {
    _isLoading = true;
    _trackingResult = null;
    _error = null;
    notifyListeners();
    try {
      _trackingResult = await ApiService.getTracking(kode);
    } catch (e) {
      _error = 'Order tidak ditemukan';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateStatus(int orderId, String status, {String? keterangan}) async {
    try {
      await ApiService.updateOrderStatus(
        orderId: orderId,
        statusOrder: status,
        keterangan: keterangan,
      );
      await fetchOrders();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
