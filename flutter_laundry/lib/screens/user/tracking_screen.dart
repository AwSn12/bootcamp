import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart';
import '../../providers/maps_provider.dart';
import '../../data/models/order_model.dart';

class TrackingScreen extends StatefulWidget {
  final String kodeOrder;
  const TrackingScreen({super.key, required this.kodeOrder});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final orderProv = context.read<OrderProvider>();
      await orderProv.fetchTracking(widget.kodeOrder);
      // Mulai polling jika order ditemukan
      final order = orderProv.trackingResult;
      if (order != null && mounted) {
        context.read<MapsProvider>().startPolling(order.idOrder);
      }
    });
  }

  @override
  void dispose() {
    context.read<MapsProvider>().stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => context.pop(),
          color: AppTheme.textDark,
        ),
        title: Text('Tracking Order', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : provider.trackingResult == null
              ? _buildNotFound()
              : _buildTrackingContent(provider.trackingResult!),
    );
  }

  Widget _buildNotFound() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Color(0xFFFEF2F2), shape: BoxShape.circle),
              child: const Icon(Icons.search_off, size: 48, color: AppTheme.error),
            ),
            const SizedBox(height: 24),
            Text('Order Tidak Ditemukan', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            const SizedBox(height: 8),
            Text('Periksa kembali kode order Anda.', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMid), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => context.go('/dashboard'),
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F172A), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14)),
              child: Text('Kembali ke Dashboard', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingContent(OrderModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TRACKING ORDER', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 2)),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                        children: [
                          const TextSpan(text: 'Status '),
                          TextSpan(text: 'Cucian', style: const TextStyle(color: AppTheme.primary)),
                        ],
                      ),
                    ),
                    Text('#${order.kodeOrder}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMid)),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.phone, size: 16),
                label: Text('Admin', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.success,
                  side: const BorderSide(color: AppTheme.success),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ─── MAP SECTION ─────────────────────────────────────────────────
          _buildMapSection(order),
          const SizedBox(height: 16),

          // Timeline Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Riwayat Status', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.primaryBg, borderRadius: BorderRadius.circular(20)),
                      child: Text('#${order.kodeOrder}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Timeline
                ...List.generate(order.tracking.length, (index) {
                  final track = order.tracking[index];
                  final isFirst = index == 0;
                  final isLast = index == order.tracking.length - 1;
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dot + Line
                        SizedBox(
                          width: 24,
                          child: Column(
                            children: [
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  color: isFirst ? AppTheme.primary : Colors.white,
                                  border: Border.all(color: isFirst ? AppTheme.primary : AppTheme.border, width: 2),
                                  shape: BoxShape.circle,
                                ),
                                child: isFirst ? const Icon(Icons.check, color: Colors.white, size: 12) : null,
                              ),
                              if (!isLast)
                                Expanded(child: Container(width: 2, color: AppTheme.border, margin: const EdgeInsets.symmetric(vertical: 4))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(track.statusTracking,
                                          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800,
                                              color: isFirst ? AppTheme.textDark : AppTheme.textLight)),
                                    ),
                                    Text(DateFormat('HH:mm').format(track.waktuUpdate),
                                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
                                  ],
                                ),
                                if (track.keterangan != null) ...[
                                  const SizedBox(height: 4),
                                  Text(track.keterangan!, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.bgLight, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('DETAIL PAKET', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text('${order.layanan?.namaLayanan ?? "Layanan"} (${order.beratKg} kg)',
                          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                      if (order.catatan != null)
                        Text('Catatan: ${order.catatan}', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Kurir & Summary
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.all(Radius.circular(20))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KURIR PENGANTAR', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 2)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.person_outline, color: AppTheme.primaryLight, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Driver LaundryKu', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15)),
                        Text('Kurir Aktif', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white10),
                const SizedBox(height: 12),
                _infoRow('ALAMAT PENJEMPUTAN', order.alamatPickup),
                const SizedBox(height: 12),
                _infoRow('ALAMAT PENGANTARAN', order.alamatDelivery),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone, size: 18),
                    label: Text('Hubungi Kurir', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.border)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('RINGKASAN LAYANAN', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 2)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: AppTheme.primaryBg, borderRadius: BorderRadius.all(Radius.circular(12))),
                      child: const Icon(Icons.local_laundry_service, color: AppTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.layanan?.namaLayanan ?? '-', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                        Text('Rp ${NumberFormat('#,###').format(order.layanan?.hargaPerKg ?? 0)}/kg',
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.bgLight, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    children: [
                      _summaryRow('Estimasi Selesai', '${order.layanan?.estimasiHari ?? "-"} Hari'),
                      const SizedBox(height: 8),
                      _summaryRow('Berat', '${order.beratKg} KG'),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('TOTAL', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                          Text('Rp ${NumberFormat('#,###').format(order.totalBayar)}',
                              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── MAP WIDGET ──────────────────────────────────────────────────────────
  Widget _buildMapSection(OrderModel order) {
    final mapsProvider = context.watch<MapsProvider>();

    final hasKurirLokasi = mapsProvider.kurirLat != null && mapsProvider.kurirLng != null;
    final lat = mapsProvider.kurirLat ?? -6.2700; // Default Cikarang
    final lng = mapsProvider.kurirLng ?? 107.1500;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12)],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Map header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Text('Lokasi Kurir', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textDark)),
                const Spacer(),
                if (hasKurirLokasi)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text('Live • Auto-refresh', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.success)),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(20)),
                    child: Text('Menunggu lokasi kurir', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFFEA580C))),
                  ),
              ],
            ),
          ),

          // Map area
          SizedBox(
            height: 220,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(lat, lng),
                    initialZoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.ravlaundry.app',
                    ),
                    if (hasKurirLokasi)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(lat, lng),
                            width: 56,
                            height: 56,
                            child: Tooltip(
                              message: 'Posisi Kurir',
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primary,
                                  boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 10, spreadRadius: 2)],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: const Icon(Icons.delivery_dining, color: Colors.white, size: 28),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (!hasKurirLokasi)
                  Container(
                    color: Colors.white.withValues(alpha: 0.75),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF7ED),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delivery_dining, color: Color(0xFFEA580C), size: 36),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Menunggu Lokasi Kurir',
                            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Info row bawah
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                _mapLegend(Icons.delivery_dining, AppTheme.primary, 'Posisi Kurir'),
                const Spacer(),
                if (hasKurirLokasi && mapsProvider.kurirLokasi != null)
                  Text(
                    'Update: ${DateFormat('HH:mm').format(mapsProvider.kurirLokasi!.updatedAt)}',
                    style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight),
                  )
                else
                  Text(
                    'Refresh otomatis setiap 5 detik',
                    style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textLight, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapLegend(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMid)),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white38, letterSpacing: 2)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid, fontWeight: FontWeight.w600)),
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
      ],
    );
  }
}
