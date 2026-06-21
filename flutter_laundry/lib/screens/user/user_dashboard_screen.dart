import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../data/models/order_model.dart';
import '../widgets/order_detail_sheet.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().fetchOrders();
    });
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'menunggu pickup': return const Color(0xFFFFF7ED);
      case 'dijemput kurir': return const Color(0xFFEFF6FF);
      case 'sedang dicuci': return const Color(0xFFEEF2FF);
      case 'sedang disetrika': return const Color(0xFFF5F3FF);
      case 'selesai': return const Color(0xFFECFDF5);
      case 'diantar': return const Color(0xFFF0F9FF);
      default: return const Color(0xFFF8FAFC);
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'menunggu pickup': return const Color(0xFFEA580C);
      case 'dijemput kurir': return AppTheme.primary;
      case 'sedang dicuci': return const Color(0xFF4F46E5);
      case 'sedang disetrika': return const Color(0xFF7C3AED);
      case 'selesai': return const Color(0xFF059669);
      case 'diantar': return const Color(0xFF0284C7);
      default: return AppTheme.textMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orders = context.watch<OrderProvider>();
    final user = auth.user;

    final activeOrders = orders.orders.where((o) => o.statusOrder != 'selesai diterima').toList();
    final historyOrders = orders.orders.where((o) => o.statusOrder == 'selesai diterima').toList();

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<OrderProvider>().fetchOrders(),
          child: CustomScrollView(
            slivers: [
              // AppBar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.white,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, ${user?.nama ?? ''} 👋', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                    Text('Pakaian bersih Anda sedang kami proses.', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {},
                    color: AppTheme.textMid,
                  ),
                  PopupMenuButton(
                    icon: CircleAvatar(
                      backgroundColor: AppTheme.primary,
                      radius: 16,
                      child: Text(user?.initials ?? '', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
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

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats
                      Row(
                        children: [
                          _StatCard(label: 'Order Aktif', value: activeOrders.length.toString(), icon: Icons.inventory_2_outlined, color: AppTheme.primary),
                          const SizedBox(width: 10),
                          _StatCard(label: 'Selesai', value: historyOrders.length.toString(), icon: Icons.check_circle_outline, color: AppTheme.success),
                          const SizedBox(width: 10),
                          const _StatCard(label: 'Poin', value: '120', icon: Icons.star_outline, color: Color(0xFFD97706)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Promo Banner
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
                                    child: Text('Limited Promo', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.primaryLight, letterSpacing: 1)),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('Diskon 30%\nLiburan Musim Panas!', style: GoogleFonts.inter(fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
                                  const SizedBox(height: 8),
                                  Text('Kode: SUMMER30', style: GoogleFonts.inter(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                            const Icon(Icons.local_offer_outlined, color: AppTheme.primaryLight, size: 48),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // LBS Banner — Laundry Terdekat
                      GestureDetector(
                        onTap: () => context.push('/laundry-terdekat'),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.location_on,
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
                                      'Laundry Terdekat 📍',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Temukan mitra laundry paling dekat dari lokasi Anda',
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white70,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Order Aktif header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: AppTheme.primary, size: 20),
                              const SizedBox(width: 6),
                              Text('Order Berjalan', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.primaryBg, borderRadius: BorderRadius.circular(20)),
                            child: Text('${activeOrders.length} Aktif',
                                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Orders List
                      if (orders.isLoading)
                        ...[1, 2].map((_) => _SkeletonCard())
                      else if (activeOrders.isEmpty)
                        _EmptyOrders()
                      else
                        ...activeOrders.map((order) => _OrderCard(
                          order: order,
                          statusBg: _statusBg(order.statusOrder),
                          statusColor: _statusColor(order.statusOrder),
                        )),

                      if (historyOrders.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Text('Riwayat Transaksi', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                        const SizedBox(height: 12),
                        ...historyOrders.map((order) => _OrderCard(
                          order: order,
                          statusBg: const Color(0xFFECFDF5),
                          statusColor: AppTheme.success,
                        )),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/order'),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Pesanan Baru', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
            Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textMid)),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final Color statusBg, statusColor;

  const _OrderCard({required this.order, required this.statusBg, required this.statusColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showOrderDetailSheet(context, order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.inventory_2_outlined, color: statusColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('#${order.kodeOrder}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textLight).copyWith(fontFamily: 'monospace')),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                            child: Text(order.statusLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                          ),
                        ],
                      ),
                      Text(order.layanan?.namaLayanan ?? 'Layanan', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.alamatPickup.length > 30 ? '${order.alamatPickup.substring(0, 30)}...' : order.alamatPickup,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid),
                  ),
                ),
                const Icon(Icons.access_time, size: 14, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Text(DateFormat('dd MMM yyyy').format(order.tanggalPickup), style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Bayar', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                    Text('Rp ${NumberFormat('#,###').format(order.totalBayar)}',
                        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => context.push('/tracking/${order.kodeOrder}'),
                  icon: const Icon(Icons.location_searching, size: 16),
                  label: Text('Track Status', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 130,
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppTheme.bgLight, shape: BoxShape.circle),
            child: const Icon(Icons.inventory_2_outlined, size: 40, color: AppTheme.textLight),
          ),
          const SizedBox(height: 16),
          Text('Belum ada order aktif', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          const SizedBox(height: 8),
          Text('Yuk, buat order laundry sekarang!', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMid)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () => context.push('/order'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Order Sekarang', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
