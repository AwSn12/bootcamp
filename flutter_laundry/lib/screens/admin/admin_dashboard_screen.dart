import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../data/models/order_model.dart';
import '../../data/services/api_service.dart';
import '../widgets/order_detail_sheet.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _searchQuery = '';
  Map<String, dynamic>? _revenueStats;
  bool _isLoadingStats = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    context.read<OrderProvider>().fetchOrders();
    setState(() => _isLoadingStats = true);
    try {
      final stats = await ApiService.getAdminRevenueStats();
      if (mounted) setState(() => _revenueStats = stats);
    } catch (e) {
      // Abaikan error untuk demo
    } finally {
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }


  Color _statusColor(String status) {
    switch (status) {
      case 'menunggu pickup': return const Color(0xFFEA580C);
      case 'dijemput kurir': return AppTheme.primary;
      case 'sedang dicuci': return const Color(0xFF4F46E5);
      case 'sedang disetrika': return const Color(0xFF7C3AED);
      case 'selesai': return AppTheme.success;
      case 'diantar': return const Color(0xFF0284C7);
      case 'selesai diterima': return AppTheme.textLight;
      default: return AppTheme.textMid;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'menunggu pickup': return const Color(0xFFFFF7ED);
      case 'dijemput kurir': return const Color(0xFFEFF6FF);
      case 'sedang dicuci': return const Color(0xFFEEF2FF);
      case 'sedang disetrika': return const Color(0xFFF5F3FF);
      case 'selesai': return const Color(0xFFECFDF5);
      case 'diantar': return const Color(0xFFF0F9FF);
      case 'selesai diterima': return const Color(0xFFF8FAFC);
      default: return const Color(0xFFF8FAFC);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();

    final completed = orders.orders.where((o) => o.statusOrder == 'selesai diterima').length;
    final pending = orders.orders.where((o) => o.statusOrder == 'menunggu pickup').length;
    final active = orders.orders.length - completed - pending;

    final filtered = _searchQuery.isEmpty
        ? orders.orders
        // YANG SALAH:
        // : orders.orders.where((o) => o.kodeOrder.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
        
        // YANG BENAR (BISA CARI BERDASARKAN LAYANAN):
        : orders.orders.where((o) {
            final query = _searchQuery.toLowerCase();
            final matchKode = o.kodeOrder.toLowerCase().contains(query);
            final matchLayanan = o.layanan?.namaLayanan.toLowerCase().contains(query) ?? false;
            return matchKode || matchLayanan;
          }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                children: const [
                  TextSpan(text: 'Admin '),
                  TextSpan(text: 'Console', style: TextStyle(color: AppTheme.primary)),
                ],
              ),
            ),
            Text('Kelola semua operasional', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textMid)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textMid),
            onPressed: _refreshData,
          ),
          PopupMenuButton(
            icon: CircleAvatar(
              backgroundColor: AppTheme.primary,
              radius: 16,
              child: Text(auth.user?.initials ?? 'AD', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            itemBuilder: (_) => [
              PopupMenuItem(
                onTap: () {
                  context.read<AuthProvider>().logout();
                  context.go('/');
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
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Stats
                    Row(
                      children: [
                        _AdminStatCard(label: 'Total', value: orders.orders.length.toString(), icon: Icons.inventory_2_outlined, color: AppTheme.primary),
                        const SizedBox(width: 8),
                        _AdminStatCard(label: 'Pending', value: pending.toString(), icon: Icons.access_time, color: const Color(0xFFEA580C)),
                        const SizedBox(width: 8),
                        _AdminStatCard(label: 'Aktif', value: active.toString(), icon: Icons.local_laundry_service, color: const Color(0xFF4F46E5)),
                        const SizedBox(width: 8),
                        _AdminStatCard(label: 'Selesai', value: completed.toString(), icon: Icons.check_circle_outline, color: AppTheme.success),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Revenue Stats
                    if (_isLoadingStats)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
                      )
                    else if (_revenueStats != null)
                      Row(
                        children: [
                          _AdminStatCard(
                            label: 'Pendapatan Hari Ini', 
                            value: 'Rp ${NumberFormat('#,###').format(_revenueStats!['harian'] ?? 0)}', 
                            icon: Icons.monetization_on_outlined, 
                            color: const Color(0xFF059669),
                          ),
                          const SizedBox(width: 8),
                          _AdminStatCard(
                            label: 'Minggu Ini', 
                            value: 'Rp ${NumberFormat('#,###').format(_revenueStats!['mingguan'] ?? 0)}', 
                            icon: Icons.account_balance_wallet_outlined, 
                            color: const Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 8),
                          _AdminStatCard(
                            label: 'Bulan Ini', 
                            value: 'Rp ${NumberFormat('#,###').format(_revenueStats!['bulanan'] ?? 0)}', 
                            icon: Icons.savings_outlined, 
                            color: const Color(0xFF7C3AED),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),

                    // Search
                    TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        // YANG SALAH: hintText: 'Cari kode order...',
                        hintText: 'Cari kode order atau layanan...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.border)),
                        filled: true, fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Orders header
                    Row(
                      children: [
                        Text('Manajemen Pesanan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                        const Spacer(),
                        Text('${filtered.length} order', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            if (orders.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primary),
                      const SizedBox(height: 16),
                      Text('Memuat data...', style: GoogleFonts.inter(color: AppTheme.textMid)),
                    ],
                  ),
                ),
              )
            else if (filtered.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(child: Text('Belum ada pesanan masuk.', style: GoogleFonts.inter(color: AppTheme.textMid))),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _AdminOrderCard(
                      order: filtered[index],
                      statusColor: _statusColor(filtered[index].statusOrder),
                      statusBg: _statusBg(filtered[index].statusOrder),
                      onStatusUpdate: (status, ket) {
                        context.read<OrderProvider>().updateStatus(filtered[index].idOrder, status, keterangan: ket);
                      },
                    ),
                    childCount: filtered.length,
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

class _AdminStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _AdminStatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            ),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMid)),
          ],
        ),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  final Color statusColor, statusBg;
  final void Function(String status, String ket) onStatusUpdate;

  const _AdminOrderCard({required this.order, required this.statusColor, required this.statusBg, required this.onStatusUpdate});

  static const List<Map<String, String>> _actions = [
    {'status': 'dijemput kurir', 'label': 'Tandai Dijemput', 'ket': 'Kurir sedang dalam perjalanan menjemput.'},
    {'status': 'sedang dicuci', 'label': 'Mulai Mencuci', 'ket': 'Pakaian sedang dalam proses pencucian.'},
    {'status': 'sedang disetrika', 'label': 'Mulai Menyetrika', 'ket': 'Proses penyetrikaan agar pakaian rapi.'},
    {'status': 'selesai', 'label': 'Tandai Selesai', 'ket': 'Laundry bersih dan rapi, siap diantar.'},
    {'status': 'diantar', 'label': 'Antarkan Laundry', 'ket': 'Kurir sedang mengantar laundry ke tujuan.'},
    {'status': 'selesai diterima', 'label': '✓ Selesai Diterima', 'ket': 'Paket telah diterima pelanggan.'},
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showOrderDetailSheet(context, order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${order.kodeOrder}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textLight).copyWith(fontFamily: 'monospace')),
                    Text(order.layanan?.namaLayanan ?? '-', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                child: Text(order.statusLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppTheme.textLight),
              const SizedBox(width: 4),
              Text('Rp ${NumberFormat('#,###').format(order.totalBayar)}',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.primary)),
              const Spacer(),
              PopupMenuButton<Map<String, String>>(
                icon: const Icon(Icons.more_vert, color: AppTheme.textMid, size: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                itemBuilder: (_) => _actions.map((a) => PopupMenuItem(
                  value: a,
                  child: Text(a['label']!, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                )).toList(),
                onSelected: (a) => onStatusUpdate(a['status']!, a['ket']!),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
