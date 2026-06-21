import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/order_model.dart';

void showOrderDetailSheet(BuildContext context, OrderModel order) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _OrderDetailSheet(order: order),
  );
}

class _OrderDetailSheet extends StatelessWidget {
  final OrderModel order;
  const _OrderDetailSheet({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Detail Pesanan', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                    const SizedBox(height: 4),
                    Text('#${order.kodeOrder}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primary).copyWith(fontFamily: 'monospace')),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primaryBg, borderRadius: BorderRadius.circular(20)),
                  child: Text(order.statusLabel, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),
            
            // Info Layanan
            Row(
              children: [
                const Icon(Icons.local_laundry_service, color: AppTheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(order.layanan?.namaLayanan ?? '-', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                const Spacer(),
                Text('${order.beratKg} Kg', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textMid)),
              ],
            ),
            const SizedBox(height: 12),
            
            // Jadwal Pickup
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.textLight, size: 20),
                const SizedBox(width: 8),
                Text(DateFormat('dd MMM yyyy').format(order.tanggalPickup), style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMid)),
                const Spacer(),
                const Icon(Icons.access_time, color: AppTheme.textLight, size: 20),
                const SizedBox(width: 8),
                Text('${order.jamPickup} WIB', style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMid)),
              ],
            ),
            const SizedBox(height: 20),
            
            // Alamat
            _buildAddress('Alamat Pickup', order.alamatPickup, Colors.red),
            const SizedBox(height: 12),
            _buildAddress('Alamat Delivery', order.alamatDelivery, AppTheme.primary),
            
            if (order.catatan != null && order.catatan!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFFF59E0B), size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(order.catatan!, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFB45309), fontStyle: FontStyle.italic))),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 24),
            
            // Rincian Biaya
            Text('Rincian Pembayaran', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textDark, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            _buildCostRow('Subtotal', order.subtotal),
            const SizedBox(height: 6),
            _buildCostRow('Ongkos Kirim', order.ongkir),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Bayar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                Text('Rp ${NumberFormat('#,###').format(order.totalBayar)}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddress(String title, String address, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textLight, letterSpacing: 1.2)),
              Text(address, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String title, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textMid)),
        Text('Rp ${NumberFormat('#,###').format(amount)}', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
      ],
    );
  }
}
