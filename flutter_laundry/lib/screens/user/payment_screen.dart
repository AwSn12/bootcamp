import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/order_provider.dart';

class PaymentScreen extends StatefulWidget {
  final String kodeOrder;
  final String metodeAwal; // "TRANSFER BANK" or "DOMPET DIGITAL"

  const PaymentScreen({super.key, required this.kodeOrder, required this.metodeAwal});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;

  @override
  void initState() {
    super.initState();
    // Refresh to get latest orders if necessary
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<OrderProvider>().orders.every((o) => o.kodeOrder != widget.kodeOrder)) {
        context.read<OrderProvider>().fetchOrders();
      }
    });
  }

  Widget _buildPaymentOption(String title, String subtitle, String iconUrl, String methodValue) {
    final selected = _selectedMethod == methodValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = methodValue),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryBg : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.border, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: selected ? AppTheme.primary : AppTheme.textLight, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                ],
              ),
            ),
            if (iconUrl.isNotEmpty) ...[
              const SizedBox(width: 12),
              Image.network(iconUrl, width: 40, height: 40, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.payment, color: AppTheme.textLight)),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().orders.where((o) => o.kodeOrder == widget.kodeOrder).firstOrNull;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => context.go('/dashboard'),
        ),
        title: Text('Pembayaran', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: order == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        Text('Total Pembayaran', style: GoogleFonts.inter(color: AppTheme.textMid, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text('Rp ${order.totalBayar.toStringAsFixed(0)}', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 24, color: AppTheme.primary)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: AppTheme.primaryBg, borderRadius: BorderRadius.circular(20)),
                          child: Text('Order: ${order.kodeOrder}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text('Pilih Metode Pembayaran', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                  const SizedBox(height: 16),

                  if (widget.metodeAwal == 'DOMPET DIGITAL') ...[
                    _buildPaymentOption('DANA', '0813-8990-3172', 'https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Logo_dana_blue.svg/1200px-Logo_dana_blue.svg.png', 'DANA'),
                    _buildPaymentOption('GoPay', '0813-8990-3172', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/86/Gopay_logo.svg/1200px-Gopay_logo.svg.png', 'GOPAY'),
                    _buildPaymentOption('ShopeePay', '0813-8990-3172', 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/fe/Shopee.svg/1200px-Shopee.svg.png', 'SHOPEEPAY'),
                    _buildPaymentOption('QRIS', 'Scan barcode dari aplikasi e-wallet Anda', 'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Logo_QRIS.svg/1200px-Logo_QRIS.svg.png', 'QRIS'),
                  ],

                  if (widget.metodeAwal == 'TRANSFER BANK') ...[
                    _buildPaymentOption('SeaBank', '9012 9757 0040', '', 'SEABANK'),
                    _buildPaymentOption('Bank Jago', '1004 6676 5402', '', 'JAGO'),
                    _buildPaymentOption('Krom Bank', '7700 2082 8048', '', 'KROM'),
                  ],

                  if (_selectedMethod != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (_selectedMethod == 'DANA' || _selectedMethod == 'SHOPEEPAY' || _selectedMethod == 'GOPAY') ...[
                            Text('Silakan transfer ke nomor berikut:', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                            const SizedBox(height: 8),
                            Text('081389903172', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Text('a.n. RAVLaundry Official', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                          ],
                          if (_selectedMethod == 'QRIS') ...[
                            Text('Scan QR Code ini untuk membayar:', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                            const SizedBox(height: 16),
                            Icon(Icons.qr_code_2, size: 150, color: AppTheme.textDark), // Placeholder QR
                            const SizedBox(height: 8),
                            Text('RAVLaundry Official', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                          ],
                          if (_selectedMethod == 'SEABANK') ...[
                            Text('Silakan transfer ke rekening berikut:', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                            const SizedBox(height: 8),
                            Text('9012 9757 0040', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Text('a.n. RAVLaundry Official', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                          ],
                          if (_selectedMethod == 'JAGO') ...[
                            Text('Silakan transfer ke rekening berikut:', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                            const SizedBox(height: 8),
                            Text('1004 6676 5402', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Text('a.n. RAVLaundry Official', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                          ],
                          if (_selectedMethod == 'KROM') ...[
                            Text('Silakan transfer ke rekening berikut:', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                            const SizedBox(height: 8),
                            Text('7700 2082 8048', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.textDark, letterSpacing: 2)),
                            const SizedBox(height: 8),
                            Text('a.n. RAVLaundry Official', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textMid)),
                          ]
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectedMethod == null
                          ? null
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status pembayaran menunggu konfirmasi Admin.'), backgroundColor: AppTheme.success));
                              context.go('/dashboard');
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Saya Sudah Bayar', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
