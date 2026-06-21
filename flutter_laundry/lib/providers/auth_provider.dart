import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/services/api_service.dart';
import '../core/utils/storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> checkAuth() async {
    final userData = await StorageService.getUser();
    final token = await StorageService.getToken();
    if (token != null && userData != null) {
      _user = UserModel.fromJson(userData);
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final result = await ApiService.login(identifier: identifier, password: password);
      _user = result.user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String nama,
    required String email,
    required String noTelp,
    required String alamat,
    required String username,
    required String password,
    String role = "USER",
  }) async {
    _status = AuthStatus.loading;
    _error = null;
    notifyListeners();
    try {
      await ApiService.register(
        nama: nama, email: email, noTelp: noTelp,
        alamat: alamat, username: username, password: password, role: role,
      );
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _error = _parseError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _parseError(dynamic e) {
    if (e is Exception) return e.toString().replaceAll('Exception: ', '');
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
