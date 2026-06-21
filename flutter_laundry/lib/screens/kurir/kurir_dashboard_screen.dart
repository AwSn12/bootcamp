import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/maps_provider.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_detail_sheet.dart';

class KurirDashboardScreen extends StatefulWidget {
  const KurirDashboardScreen({super.key});

  @override
  State<KurirDashboardScreen> createState() => _KurirDashboardScreenState();
}

class _KurirDashboardScreenState extends State<KurirDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProv = context.watch<OrderProvider>();

    final relevantStatuses = ['menunggu pickup', 'dijemput kurir', 'selesai', 'diantar'];
    final orders = orderProv.orders.where((o) => relevantStatuses.contains(o.statusOrder)).toList();
    final pickupCount = orders.where((o) => o.statusOrder == 'menunggu pickup').length;
    final deliveryCount = orders.where((o) => o.statusOrder == 'selesai').length;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: RichText(
          text: TextSpan(
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark),
            children: const [
              TextSpan(text: 'Kurir '),
              TextSpan(text: 'Dashboard', style: TextStyle(color: AppTheme.primary)),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: AppTheme.textMid), onPressed: () => context.read<OrderProvider>().fetchOrders()),
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundColor: AppTheme.primary,
              radius: 16,
              child: Text(auth.user?.initials ?? 'KR', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go('/');
                },
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: AppTheme.error, size: 18),
                    const SizedBox(width: 8),
                    Text('Logout', style: GoogleFonts.inter(color: AppTheme.error, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<OrderProvider>().fetchOrders(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Courier ID Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.all(Radius.circular(20))),
                      child: Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(14)),
                            child: const Icon(Icons.delivery_dining, color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('COURIER MODE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 2)),
                                Text(auth.user?.nama ?? 'Kurir', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                                Text('Drive. Pickup. Deliver.', style: GoogleFonts.inter(fontSize: 11, color: Colors.white54, fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: AppTheme.success, borderRadius: BorderRadius.circular(20)),
                            child: Text('ONLINE', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
                            child: Column(
                              children: [
                                Text('$pickupCount', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFFEA580C))),
                                Text('Pickup Hari Ini', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMid)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
                            child: Column(
                              children: [
                                Text('$deliveryCount', style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                                Text('Delivery Hari Ini', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMid)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ─── KURIR LOKASI PANEL (Realtime Tracking) ──────────────
                    const _KurirLokasiPanel(),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Icon(Icons.navigation, color: AppTheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Tugas Aktif', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            if (orderProv.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      ...[1, 2].map((_) => Container(margin: const EdgeInsets.only(bottom: 12), height: 200, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)))),
                    ],
                  ),
                ),
              )
            else if (orders.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border)),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(color: AppTheme.bgLight, shape: BoxShape.circle),
                          child: const Icon(Icons.check_circle_outline, size: 40, color: AppTheme.textLight),
                        ),
                        const SizedBox(height: 16),
                        Text('Semua Tugas Selesai!', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                        const SizedBox(height: 8),
                        Text('Waktunya istirahat sejenak.', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMid, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _KurirOrderCard(
                      order: orders[index],
                      onUpdate: (status, ket) => context.read<OrderProvider>().updateStatus(orders[index].idOrder, status, keterangan: ket),
                    ),
                    childCount: orders.length,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

// ─── Order Card (TANPA tombol kamera) ────────────────────────────────────────
class _KurirOrderCard extends StatelessWidget {
  final OrderModel order;
  final void Function(String status, String ket) onUpdate;

  const _KurirOrderCard({required this.order, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final isPickup = order.statusOrder.contains('pickup');
    return GestureDetector(
      onTap: () => showOrderDetailSheet(context, order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(6)),
                        child: Text('ORD-#${order.kodeOrder}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white).copyWith(fontFamily: 'monospace')),
                      ),
                      const SizedBox(height: 6),
                      Text(order.layanan?.namaLayanan ?? '-', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Text('${order.jamPickup} WIB', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isPickup ? const Color(0xFFFFF7ED) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    isPickup ? Icons.inventory_2_outlined : Icons.local_shipping_outlined,
                    color: isPickup ? const Color(0xFFEA580C) : AppTheme.primary,
                    size: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Address & Customer
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.red, shadows: []),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ALAMAT TUJUAN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 1.5)),
                      Text(
                        isPickup ? order.alamatPickup : order.alamatDelivery,
                        style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Button ONLY (tombol kamera dihapus)
            SizedBox(width: double.infinity, child: _buildActionButton(order)),
          ],
        ),
      ),
    ));
  }

  Widget _buildActionButton(OrderModel order) {
    switch (order.statusOrder) {
      case 'menunggu pickup':
        return FilledButton.icon(
          onPressed: () => onUpdate('dijemput kurir', 'Kurir sudah mengambil pakaian. Sedang menuju workshop.'),
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Konfirmasi Pickup'),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEA580C), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      case 'dijemput kurir':
        return FilledButton.icon(
          onPressed: () => onUpdate('sedang dicuci', 'Pakaian telah sampai di workshop dan mulai diproses.'),
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: const Text('Serahkan ke Workshop'),
          style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      case 'selesai':
        return FilledButton.icon(
          onPressed: () => onUpdate('diantar', 'Laundry bersih Anda sedang dalam perjalanan ke alamat tujuan.'),
          icon: const Icon(Icons.local_shipping, size: 18),
          label: const Text('Ambil & Antar'),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      case 'diantar':
        return FilledButton.icon(
          onPressed: () => onUpdate('selesai diterima', 'Paket telah diterima dengan baik. Terima kasih!'),
          icon: const Icon(Icons.done_all, size: 18),
          label: const Text('Selesaikan Pengantaran'),
          style: FilledButton.styleFrom(backgroundColor: AppTheme.success, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      default:
        return const SizedBox();
    }
  }
}

// ─── Panel Lokasi Kurir — Realtime Tracking ──────────────────────────────────
class _KurirLokasiPanel extends StatefulWidget {
  const _KurirLokasiPanel();

  @override
  State<_KurirLokasiPanel> createState() => _KurirLokasiPanelState();
}

class _KurirLokasiPanelState extends State<_KurirLokasiPanel> {
  // ── Tracking State ──────────────────────────────────────────
  bool _isTracking = false;
  Timer? _trackingTimer;
  double? _lastLat;
  double? _lastLng;
  String? _lastAddress;
  DateTime? _lastUpdated;
  bool _isSending = false;
  final MapController _mapController = MapController();

  // ── Manual/Preset State ─────────────────────────────────────
  final _latCtrl = TextEditingController(text: '-6.2700');
  final _lngCtrl = TextEditingController(text: '107.1500');
  bool _expandedManual = false;

  @override
  void dispose() {
    _stopTracking();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  // ── Permission helper ─────────────────────────────────────────
  Future<bool> _requestPermission() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('GPS tidak aktif. Nyalakan lokasi di pengaturan.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Buka',
            textColor: Colors.white,
            onPressed: () => Geolocator.openLocationSettings(),
          ),
        ),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin lokasi ditolak.'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Izin lokasi diblokir. Buka pengaturan aplikasi.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Pengaturan',
            textColor: Colors.white,
            onPressed: () => Geolocator.openAppSettings(),
          ),
        ),
      );
      return false;
    }

    return true;
  }

  // ── Ambil & kirim satu lokasi GPS ─────────────────────────────
  Future<void> _fetchAndSendLocation() async {
    if (_isSending || !mounted) return;
    setState(() => _isSending = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      if (!mounted) return;

      // Reverse geocoding untuk alamat
      String address = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          final parts = <String>[];
          if (p.street != null && p.street!.isNotEmpty) parts.add(p.street!);
          if (p.subLocality != null && p.subLocality!.isNotEmpty) parts.add(p.subLocality!);
          if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
          if (parts.isNotEmpty) address = parts.join(', ');
        }
      } catch (_) {
        // Geocoding gagal — tetap gunakan koordinat
      }

      // Kirim ke backend
      if (!mounted) return;
      final mapsProvider = context.read<MapsProvider>();
      await mapsProvider.sendKurirLokasi(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _lastLat = position.latitude;
        _lastLng = position.longitude;
        _lastAddress = address;
        _lastUpdated = DateTime.now();
        _isSending = false;
      });
      try {
        _mapController.move(LatLng(position.latitude, position.longitude), 15);
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        // Jika terjadi error saat tracking, hentikan tracking
        if (_isTracking) {
          _stopTracking();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('GPS error, tracking dihentikan: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  // ── Mulai Tracking Otomatis ────────────────────────────────────
  Future<void> _startTracking() async {
    final ok = await _requestPermission();
    if (!ok || !mounted) return;

    setState(() => _isTracking = true);

    // Langsung ambil lokasi pertama
    await _fetchAndSendLocation();

    // Ulangi setiap 5 detik
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted && _isTracking) _fetchAndSendLocation();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🟢 Tracking aktif! Lokasi diperbarui setiap 5 detik.'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  // ── Hentikan Tracking ──────────────────────────────────────────
  void _stopTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    if (mounted) {
      setState(() {
        _isTracking = false;
        _isSending = false;
      });
    }
  }

  // ── Kirim Preset / Manual ──────────────────────────────────────
  Future<void> _sendManual() async {
    final lat = double.tryParse(_latCtrl.text);
    final lng = double.tryParse(_lngCtrl.text);
    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Latitude dan Longitude harus berupa angka.'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    final mapsProvider = context.read<MapsProvider>();
    final ok = await mapsProvider.sendKurirLokasi(latitude: lat, longitude: lng);
    if (!mounted) return;
    if (ok) {
      setState(() {
        _lastLat = lat;
        _lastLng = lng;
        _lastAddress = 'Lokasi manual: $lat, $lng';
        _lastUpdated = DateTime.now();
      });
      try {
        _mapController.move(LatLng(lat, lng), 15);
      } catch (_) {}
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? '📍 Lokasi manual berhasil dikirim!' : (mapsProvider.error ?? 'Gagal kirim lokasi')),
        backgroundColor: ok ? AppTheme.success : AppTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isTracking ? AppTheme.success : AppTheme.border,
          width: _isTracking ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isTracking ? const Color(0xFFECFDF5) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isTracking ? AppTheme.success : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isTracking ? Icons.my_location : Icons.location_on_outlined,
                    color: _isTracking ? Colors.white : AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'GPS Tracking Kurir',
                        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                      ),
                      Text(
                        _isTracking
                            ? '🟢 Tracking aktif — update otomatis setiap 5 detik'
                            : 'Kirim posisi GPS ke sistem secara otomatis',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: _isTracking ? AppTheme.success : AppTheme.textMid,
                          fontWeight: _isTracking ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isSending)
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.success),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Status Lokasi Terakhir ────────────────────────────
                if (_lastLat != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppTheme.success, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'POSISI TERAKHIR',
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 1.5),
                            ),
                            const Spacer(),
                            if (_lastUpdated != null)
                              Text(
                                DateFormat('HH:mm:ss').format(_lastUpdated!),
                                style: GoogleFonts.inter(fontSize: 10, color: Colors.white38),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // MAP WIDGET
                        SizedBox(
                          height: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: LatLng(_lastLat!, _lastLng!),
                                initialZoom: 15,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.ravlaundry.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(_lastLat!, _lastLng!),
                                      width: 40,
                                      height: 40,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.primary,
                                          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 6, spreadRadius: 2)],
                                        ),
                                        child: const Icon(Icons.delivery_dining, color: Colors.white, size: 20),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _lastAddress ?? '${_lastLat!.toStringAsFixed(6)}, ${_lastLng!.toStringAsFixed(6)}',
                          style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lat: ${_lastLat!.toStringAsFixed(6)}  |  Lng: ${_lastLng!.toStringAsFixed(6)}',
                          style: GoogleFonts.inconsolata(fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ── Tombol Mulai / Berhenti Tracking ─────────────────
                Row(
                  children: [
                    Expanded(
                      child: _isTracking
                          ? FilledButton.icon(
                              onPressed: () {
                                _stopTracking();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🔴 Tracking dihentikan.'),
                                    backgroundColor: AppTheme.error,
                                    behavior: SnackBarBehavior.floating,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.stop_circle_outlined, size: 20),
                              label: Text('Berhenti Tracking', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.error,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            )
                          : FilledButton.icon(
                              onPressed: _startTracking,
                              icon: const Icon(Icons.play_circle_outlined, size: 20),
                              label: Text('Mulai Tracking', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.success,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                    ),
                    if (_isTracking) ...[
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: _isSending ? null : _fetchAndSendLocation,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: Text('Update', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.success,
                          side: const BorderSide(color: AppTheme.success),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _isTracking
                      ? 'Tekan "Berhenti" untuk menghentikan tracking. Lokasi diperbarui otomatis.'
                      : 'Tekan "Mulai Tracking" untuk kirim lokasi GPS secara otomatis.',
                  style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight),
                  textAlign: TextAlign.center,
                ),

                // ── Mode Manual / Preset (fallback) ──────────────────
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => setState(() => _expandedManual = !_expandedManual),
                  child: Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Text(
                              'MODE MANUAL / DEMO',
                              style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 1.5),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _expandedManual ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: AppTheme.textLight,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),

                if (_expandedManual) ...[
                  const SizedBox(height: 12),

                  // Preset locations
                  Text('LOKASI PRESET (Area Cikarang)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _presetBtn('Cikarang Utara', -6.2641, 107.1480),
                      _presetBtn('Cikarang Pusat', -6.2890, 107.1555),
                      _presetBtn('Jababeka', -6.2804, 107.1623),
                      _presetBtn('Lippo Cikarang', -6.2520, 107.1390),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Manual input
                  Text('INPUT KOORDINAT MANUAL', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latCtrl,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Latitude',
                            hintText: '-6.xxxx',
                            prefixIcon: Icon(Icons.north, size: 16, color: AppTheme.textLight),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _lngCtrl,
                          keyboardType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            hintText: '107.xxxx',
                            prefixIcon: Icon(Icons.east, size: 16, color: AppTheme.textLight),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _sendManual,
                      icon: const Icon(Icons.send, size: 16),
                      label: Text('Kirim Lokasi Manual', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetBtn(String label, double lat, double lng) {
    return GestureDetector(
      onTap: () {
        _latCtrl.text = lat.toString();
        _lngCtrl.text = lng.toString();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMid)),
      ),
    );
  }
}
