import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/lbs_provider.dart';
import '../../data/models/mitra_laundry_model.dart';

class LaundryTerdekatScreen extends StatefulWidget {
  const LaundryTerdekatScreen({super.key});

  @override
  State<LaundryTerdekatScreen> createState() => _LaundryTerdekatScreenState();
}

class _LaundryTerdekatScreenState extends State<LaundryTerdekatScreen> {
  bool _showDebugPanel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LbsProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lbs = context.watch<LbsProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<LbsProvider>().refresh(),
          child: CustomScrollView(
            slivers: [
              // ─── AppBar ──────────────────────────────────────────────────
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppTheme.textDark),
                  onPressed: () => context.pop(),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laundry Terdekat 📍',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      lbs.statusGps,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: lbs.hasLocation
                            ? AppTheme.success
                            : AppTheme.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Tombol debug untuk jurnal
                  IconButton(
                    tooltip: 'Panel Debug Jurnal',
                    icon: Icon(
                      _showDebugPanel
                          ? Icons.bug_report
                          : Icons.bug_report_outlined,
                      color: _showDebugPanel
                          ? AppTheme.primary
                          : AppTheme.textMid,
                    ),
                    onPressed: () =>
                        setState(() => _showDebugPanel = !_showDebugPanel),
                  ),
                  // Refresh GPS
                  lbs.isGettingLocation
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primary),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.my_location,
                              color: AppTheme.primary),
                          onPressed: () =>
                              context.read<LbsProvider>().getUserLocation(),
                          tooltip: 'Perbarui Lokasi GPS',
                        ),
                  const SizedBox(width: 8),
                ],
              ),

              // ─── GPS Status Card ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GPS Info Card
                      _GpsInfoCard(lbs: lbs),
                      const SizedBox(height: 12),

                      // Debug Panel (collapsible, untuk jurnal)
                      if (_showDebugPanel) ...[
                        _DebugUserPanel(lbs: lbs),
                        const SizedBox(height: 12),
                      ],

                      // Header daftar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.store_mall_directory_outlined,
                                  color: AppTheme.primary, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'Daftar Laundry',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textDark,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${lbs.mitraSorted.where((m) => m.statusAktif).length} Aktif',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lbs.hasLocation
                            ? 'Diurutkan dari jarak terdekat ↓'
                            : 'Aktifkan GPS untuk melihat jarak',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textLight,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ─── Loading State ───────────────────────────────────────────
              if (lbs.isLoading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => const _SkeletonCard(),
                    childCount: 5,
                  ),
                )
              // ─── Error State ─────────────────────────────────────────────
              else if (lbs.error != null)
                SliverToBoxAdapter(
                  child: _ErrorWidget(
                    message: lbs.error!,
                    onRetry: () => context.read<LbsProvider>().refresh(),
                  ),
                )
              // ─── Empty State ─────────────────────────────────────────────
              else if (lbs.mitraSorted.isEmpty)
                const SliverToBoxAdapter(child: _EmptyWidget())
              // ─── List Mitra Laundry ──────────────────────────────────────
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final mitra = lbs.mitraSorted[i];
                        return _MitraCard(
                          mitra: mitra,
                          rank: i + 1,
                          hasLocation: lbs.hasLocation,
                          showDebug: _showDebugPanel,
                          onTap: () => context.push(
                            '/laundry-terdekat/${mitra.id}',
                            extra: {
                              'mitra': mitra,
                              'userLat': lbs.userLat,
                              'userLng': lbs.userLng,
                            },
                          ),
                        );
                      },
                      childCount: lbs.mitraSorted.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── GPS Info Card ────────────────────────────────────────────────────────────
class _GpsInfoCard extends StatelessWidget {
  final LbsProvider lbs;
  const _GpsInfoCard({required this.lbs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: lbs.hasLocation
            ? const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              lbs.hasLocation ? Icons.location_on : Icons.location_off,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lbs.hasLocation ? 'Lokasi Anda' : 'GPS Tidak Aktif',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lbs.hasLocation
                      ? '${lbs.userLat!.toStringAsFixed(6)}, ${lbs.userLng!.toStringAsFixed(6)}'
                      : lbs.statusGps,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (lbs.isGettingLocation)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          else if (!lbs.hasLocation)
            TextButton(
              onPressed: () => context.read<LbsProvider>().getUserLocation(),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white24,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Aktifkan',
                  style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

// ─── Debug Panel (untuk pengujian jurnal) ────────────────────────────────────
class _DebugUserPanel extends StatelessWidget {
  final LbsProvider lbs;
  const _DebugUserPanel({required this.lbs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science_outlined, color: Color(0xFF38BDF8), size: 16),
              const SizedBox(width: 6),
              Text(
                'Panel Debug — Data GPS User (Jurnal)',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF38BDF8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DebugRow(label: 'Latitude User', value: lbs.userLat?.toStringAsFixed(7) ?? 'Belum ada'),
          _DebugRow(label: 'Longitude User', value: lbs.userLng?.toStringAsFixed(7) ?? 'Belum ada'),
          _DebugRow(label: 'Status GPS', value: lbs.statusGps),
          _DebugRow(label: 'Jumlah Mitra', value: '${lbs.mitraSorted.length} mitra laundry'),
          _DebugRow(
            label: 'Sorted by',
            value: lbs.hasLocation ? 'Jarak Haversine ↑' : 'Belum terurut',
          ),
        ],
      ),
    );
  }
}

class _DebugRow extends StatelessWidget {
  final String label;
  final String value;
  const _DebugRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inconsolata(
                  fontSize: 11, color: const Color(0xFF94A3B8)),
            ),
          ),
          const Text(' : ',
              style: TextStyle(color: Color(0xFF475569), fontSize: 11)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inconsolata(
                  fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mitra Card ───────────────────────────────────────────────────────────────
class _MitraCard extends StatelessWidget {
  final MitraLaundryModel mitra;
  final int rank;
  final bool hasLocation;
  final bool showDebug;
  final VoidCallback onTap;

  const _MitraCard({
    required this.mitra,
    required this.rank,
    required this.hasLocation,
    required this.showDebug,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isAktif = mitra.statusAktif;

    return GestureDetector(
      onTap: isAktif ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAktif ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAktif ? AppTheme.border : const Color(0xFFCBD5E1),
          ),
          boxShadow: isAktif
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank badge
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: rank <= 3
                        ? [
                            const Color(0xFFFEF3C7),
                            const Color(0xFFF1F5F9),
                            const Color(0xFFFEF0C7)
                          ][rank - 1]
                        : AppTheme.primaryBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      rank <= 3
                          ? ['🥇', '🥈', '🥉'][rank - 1]
                          : '$rank',
                      style: GoogleFonts.inter(
                        fontSize: rank <= 3 ? 16 : 13,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mitra.namaLaundry,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: isAktif
                                    ? AppTheme.textDark
                                    : AppTheme.textLight,
                              ),
                            ),
                          ),
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isAktif
                                  ? AppTheme.primaryBg
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isAktif ? 'Buka' : 'Tutup',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isAktif
                                    ? AppTheme.primary
                                    : AppTheme.textLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 13, color: AppTheme.textLight),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              mitra.alamat,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textMid,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                // Jarak
                Expanded(
                  child: _InfoChip(
                    icon: Icons.straighten_outlined,
                    label: 'Jarak',
                    value: hasLocation
                        ? mitra.jarakFormatted
                        : '—',
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                // Harga
                Expanded(
                  child: _InfoChip(
                    icon: Icons.paid_outlined,
                    label: 'Harga',
                    value:
                        'Rp ${mitra.hargaPerKg.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}/kg',
                    color: AppTheme.success,
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Detail
                if (isAktif)
                  ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: Text(
                      'Detail',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
              ],
            ),

            // Debug info (jika debug panel aktif)
            if (showDebug && hasLocation) ...[
              const SizedBox(height: 10),
              _DebugHaversineRow(mitra: mitra),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _InfoChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Debug Haversine mini panel ───────────────────────────────────────────────
class _DebugHaversineRow extends StatelessWidget {
  final MitraLaundryModel mitra;
  const _DebugHaversineRow({required this.mitra});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🔬 Haversine Debug',
            style: GoogleFonts.inconsolata(
                fontSize: 10, color: const Color(0xFF38BDF8)),
          ),
          const SizedBox(height: 4),
          Text(
            'Lat Laundry: ${mitra.latitude.toStringAsFixed(7)}\n'
            'Lng Laundry: ${mitra.longitude.toStringAsFixed(7)}\n'
            'Jarak: ${mitra.jarakKm?.toStringAsFixed(6) ?? "-"} km',
            style: GoogleFonts.inconsolata(
                fontSize: 10, color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton Card ────────────────────────────────────────────────────────────
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ─── Error Widget ─────────────────────────────────────────────────────────────
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppTheme.textMid)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}

// ─── Empty Widget ─────────────────────────────────────────────────────────────
class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: AppTheme.bgLight, shape: BoxShape.circle),
            child: const Icon(Icons.store_mall_directory_outlined,
                size: 40, color: AppTheme.textLight),
          ),
          const SizedBox(height: 16),
          Text('Belum ada mitra laundry',
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text('Data mitra laundry belum tersedia.',
              style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMid)),
        ],
      ),
    );
  }
}
