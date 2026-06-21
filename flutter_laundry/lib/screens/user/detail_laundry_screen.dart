import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/haversine_util.dart';
import '../../data/models/mitra_laundry_model.dart';

class DetailLaundryScreen extends StatelessWidget {
  final MitraLaundryModel mitra;
  final double? userLat;
  final double? userLng;

  const DetailLaundryScreen({
    super.key,
    required this.mitra,
    this.userLat,
    this.userLng,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = userLat != null && userLng != null;
    final detail = hasLocation
        ? HaversineUtil.detailPerhitungan(
            lat1: userLat!,
            lon1: userLng!,
            lat2: mitra.latitude,
            lon2: mitra.longitude,
          )
        : null;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: CustomScrollView(
        slivers: [
          // ─── SliverAppBar dengan gradient ──────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: AppTheme.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.local_laundry_service,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mitra.namaLaundry,
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: mitra.statusAktif
                                          ? Colors.white24
                                          : Colors.black26,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      mitra.statusAktif ? '● Buka' : '● Tutup',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Content ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jarak & Harga
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.straighten_outlined,
                          label: 'Jarak dari Anda',
                          value: hasLocation ? mitra.jarakFormatted : 'GPS off',
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.paid_outlined,
                          label: 'Harga per Kg',
                          value: mitra.hargaFormatted,
                          color: AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Info Laundry ─────────────────────────────────────
                  _SectionCard(
                    title: 'Informasi Laundry',
                    icon: Icons.info_outline,
                    children: [
                      _InfoRow(
                        label: 'Nama',
                        value: mitra.namaLaundry,
                        icon: Icons.store_outlined,
                      ),
                      _InfoRow(
                        label: 'Alamat',
                        value: mitra.alamat,
                        icon: Icons.location_on_outlined,
                      ),
                      _InfoRow(
                        label: 'Status',
                        value: mitra.statusAktif ? 'Buka' : 'Tutup',
                        icon: Icons.toggle_on_outlined,
                        valueColor: mitra.statusAktif
                            ? AppTheme.success
                            : AppTheme.error,
                      ),
                      _InfoRow(
                        label: 'Harga/kg',
                        value: mitra.hargaFormatted,
                        icon: Icons.payments_outlined,
                        valueColor: AppTheme.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Koordinat GPS ────────────────────────────────────
                  _SectionCard(
                    title: 'Koordinat GPS',
                    icon: Icons.gps_fixed,
                    children: [
                      _InfoRow(
                        label: 'Latitude',
                        value: mitra.latitude.toStringAsFixed(7),
                        icon: Icons.north_outlined,
                        monospace: true,
                        onCopy: () => _copyToClipboard(
                            context, mitra.latitude.toString()),
                      ),
                      _InfoRow(
                        label: 'Longitude',
                        value: mitra.longitude.toStringAsFixed(7),
                        icon: Icons.east_outlined,
                        monospace: true,
                        onCopy: () => _copyToClipboard(
                            context, mitra.longitude.toString()),
                      ),
                      if (hasLocation) ...[
                        const Divider(height: 16),
                        _InfoRow(
                          label: 'Lat User',
                          value: userLat!.toStringAsFixed(7),
                          icon: Icons.person_pin_circle_outlined,
                          monospace: true,
                          valueColor: AppTheme.primary,
                        ),
                        _InfoRow(
                          label: 'Lng User',
                          value: userLng!.toStringAsFixed(7),
                          icon: Icons.person_pin_circle_outlined,
                          monospace: true,
                          valueColor: AppTheme.primary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Panel Haversine (untuk jurnal) ───────────────────
                  if (detail != null) ...[
                    _HaversinePanel(detail: detail),
                    const SizedBox(height: 16),
                  ],

                  // ─── Tombol Order ─────────────────────────────────────
                  if (mitra.statusAktif) ...[
                    ElevatedButton.icon(
                      onPressed: () => context.push('/order'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      icon: const Icon(Icons.add_shopping_cart,
                          color: Colors.white),
                      label: Text(
                        'Buat Pesanan Laundry',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Disalin: $text',
            style: GoogleFonts.inter(fontSize: 13)),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.textDark,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ─── Haversine Detail Panel ───────────────────────────────────────────────────
class _HaversinePanel extends StatefulWidget {
  final Map<String, dynamic> detail;
  const _HaversinePanel({required this.detail});

  @override
  State<_HaversinePanel> createState() => _HaversinePanelState();
}

class _HaversinePanelState extends State<_HaversinePanel> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final d = widget.detail;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.science_outlined,
                      color: Color(0xFF38BDF8), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tabel Perhitungan Haversine (Jurnal)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, color: Color(0xFF1E293B)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _HRow('R (Jari-jari Bumi)', '${d['R']} km'),
                  _HRow('Lat User (°)', d['lat_user'].toStringAsFixed(7)),
                  _HRow('Lng User (°)', d['lon_user'].toStringAsFixed(7)),
                  _HRow('Lat Laundry (°)', d['lat_laundry'].toStringAsFixed(7)),
                  _HRow('Lng Laundry (°)', d['lon_laundry'].toStringAsFixed(7)),
                  _HRow('ΔLat (°)', d['delta_lat_deg'].toStringAsFixed(7)),
                  _HRow('ΔLng (°)', d['delta_lon_deg'].toStringAsFixed(7)),
                  _HRow('ΔLat (rad)', d['delta_lat_rad'].toStringAsFixed(8)),
                  _HRow('ΔLng (rad)', d['delta_lon_rad'].toStringAsFixed(8)),
                  _HRow('Nilai a', d['nilai_a'].toStringAsFixed(10)),
                  _HRow('Nilai c', d['nilai_c'].toStringAsFixed(8)),
                  const Divider(height: 16, color: Color(0xFF1E293B)),
                  _HRow(
                    '✅ Jarak (km)',
                    '${d['jarak_km'].toStringAsFixed(4)} km',
                    highlight: true,
                  ),
                  _HRow(
                    '✅ Jarak (m)',
                    '${d['jarak_m'].toStringAsFixed(1)} m',
                    highlight: true,
                  ),
                  const SizedBox(height: 8),
                  // Formula display
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'd = 2R × atan2(√a, √(1−a))\n'
                      'a = sin²(Δlat/2) + cos(φ₁)·cos(φ₂)·sin²(Δλ/2)',
                      style: GoogleFonts.inconsolata(
                        fontSize: 10,
                        color: const Color(0xFF94A3B8),
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _HRow(this.label, this.value, {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: GoogleFonts.inconsolata(
                fontSize: 11,
                color: highlight
                    ? const Color(0xFF4ADE80)
                    : const Color(0xFF94A3B8),
                fontWeight:
                    highlight ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: GoogleFonts.inconsolata(
                fontSize: 11,
                color: highlight ? Colors.white : const Color(0xFFCBD5E1),
                fontWeight:
                    highlight ? FontWeight.w700 : FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _SectionCard(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final bool monospace;
  final VoidCallback? onCopy;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.monospace = false,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppTheme.textLight),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: monospace
                  ? GoogleFonts.inconsolata(
                      fontSize: 13,
                      color: valueColor ?? AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    )
                  : GoogleFonts.inter(
                      fontSize: 13,
                      color: valueColor ?? AppTheme.textDark,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
          if (onCopy != null)
            GestureDetector(
              onTap: onCopy,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.copy_outlined,
                    size: 14, color: AppTheme.textLight),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppTheme.textMid,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
