// const String baseUrl = 'http://10.0.2.2:3000'; // Android emulator → localhost
// const String baseUrl = 'http://localhost:3000'; // Web/desktop
// const String baseUrl = 'http://10.211.39.146:3000'; // Fisik device, ganti dengan IP komputer
const String baseUrl = 'https://bootcamp-production-c1fe.up.railway.app';

class ApiEndpoints {
  // AUTH
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';

  // LAYANAN
  static const String layanan = '/api/layanan';

  // ORDERS
  static const String orders = '/api/orders';
  static String orderStatus(int id) => '/api/orders/$id/status';

  // PROMO
  static String checkPromo(String kode) => '/api/promo/check?kode=$kode';

  // TRACKING
  static String tracking(String kode) => '/api/tracking/$kode';

  // KURIR LOKASI (Maps)
  static const String kurirLokasi = '/api/kurir/lokasi';
  static String kurirLokasiById(int idKurir) => '/api/kurir/lokasi/$idKurir';
  static String kurirLokasiByOrder(int idOrder) => '/api/kurir/lokasi-by-order/$idOrder';

  // LBS — MITRA LAUNDRY (Location Based Service)
  static const String mitraLaundry = '/api/laundry-mitra';
  static String mitraLaundryById(int id) => '/api/laundry-mitra/$id';

  // STATISTIK ADMIN
  static const String adminRevenueStats = '/api/admin/stats/revenue';
}
