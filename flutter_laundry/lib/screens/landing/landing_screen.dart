import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.local_laundry_service, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                    children: const [
                      TextSpan(text: 'LAUNDRY'),
                      TextSpan(text: 'KU', style: TextStyle(color: AppTheme.primary)),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.push('/login'),
                child: Text('Login', style: GoogleFonts.inter(color: AppTheme.textMid, fontWeight: FontWeight.w600)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton(
                  onPressed: () => context.push('/register'),
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
                  child: Text('Daftar', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ─── Hero Section ─────────────────────────────────────────
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFEFF6FF), Colors.white],
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  child: Column(
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBg,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up, color: AppTheme.primary, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'MODERN LAUNDRY EXPERIENCE',
                              style: GoogleFonts.inter(
                                fontSize: 11, fontWeight: FontWeight.w800,
                                color: AppTheme.primary, letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Headline
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.textDark, height: 1.1),
                          children: const [
                            TextSpan(text: 'Cucian '),
                            TextSpan(text: 'Bersih', style: TextStyle(color: AppTheme.primary)),
                            TextSpan(text: ', Hidup Lebih '),
                            TextSpan(text: 'Ringan.', style: TextStyle(color: AppTheme.primary)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Solusi laundry satu atap untuk keluarga modern. Urusan mencuci, biarkan kami yang menangani.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textMid, height: 1.6),
                      ),
                      const SizedBox(height: 32),
                      // CTA Buttons
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => context.push('/register'),
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              label: Text('Mulai Sekarang', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                side: const BorderSide(color: AppTheme.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text('Cek Harga', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppTheme.textMid)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ─── Services Section ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text('OUR SPECIALTIES',
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary, letterSpacing: 2)),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text('Layanan Unggulan Kami',
                            style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
                      ),
                      const SizedBox(height: 24),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                        children: const [
                          _ServiceCard(name: 'Laundry Kiloan', price: 'Rp 6.000/kg', icon: Icons.local_laundry_service, color: Color(0xFFDEF0FF), iconColor: AppTheme.primary),
                          _ServiceCard(name: 'Cuci Satuan', price: 'Mulai Rp 15.000', icon: Icons.check_circle_outline, color: Color(0xFFEDE9FE), iconColor: Color(0xFF7C3AED)),
                          _ServiceCard(name: 'Laundry Sepatu', price: 'Mulai Rp 25.000', icon: Icons.sports_soccer, color: Color(0xFFFFF7ED), iconColor: Color(0xFFEA580C)),
                          _ServiceCard(name: 'Laundry Karpet', price: 'Rp 15.000/m', icon: Icons.crop_square, color: Color(0xFFECFDF5), iconColor: Color(0xFF059669)),
                        ],
                      ),
                    ],
                  ),
                ),

                // ─── Features Section ──────────────────────────────────────
                Container(
                  color: const Color(0xFF0F172A),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KENAPA LAUNDRYKU?',
                          style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primaryLight, letterSpacing: 2)),
                      const SizedBox(height: 8),
                      Text('Solusi Modern\nCucian Masa Kini',
                          style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
                      const SizedBox(height: 32),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                        children: const [
                          _FeatureCard(title: 'Pickup & Delivery', desc: 'Kurir jemput & antar langsung ke depan pintu.', icon: Icons.local_shipping_outlined),
                          _FeatureCard(title: 'Selesai 1 Hari', desc: 'Layanan Express siap pakai dalam 24 jam.', icon: Icons.access_time),
                          _FeatureCard(title: 'Higienis & Wangi', desc: 'Deterjen premium & parfum tahan lama.', icon: Icons.verified_outlined),
                          _FeatureCard(title: 'Tracking Real-time', desc: 'Pantau status cucian lewat aplikasi.', icon: Icons.location_on_outlined),
                        ],
                      ),
                    ],
                  ),
                ),

                // ─── CTA Section ──────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Siap Mencuci Lebih\nHemat & Nyaman?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: Text('WELCOME20', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800).copyWith(fontFamily: 'monospace')),
                      ),
                      const SizedBox(height: 8),
                      Text('Diskon 20% untuk order pertama!',
                          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => context.push('/register'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('Daftar Sekarang', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => context.push('/login'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text('Masuk ke Akun', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer
                Container(
                  color: const Color(0xFF0F172A),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      '© 2026 LAUNDRYKU. All rights reserved.',
                      style: GoogleFonts.inter(fontSize: 12, color: Colors.white38),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String name, price;
  final IconData icon;
  final Color color, iconColor;

  const _ServiceCard({required this.name, required this.price, required this.icon, required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textDark)),
          const SizedBox(height: 4),
          Text(price, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.primary)),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title, desc;
  final IconData icon;

  const _FeatureCard({required this.title, required this.desc, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: AppTheme.primaryLight, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white)),
          const SizedBox(height: 4),
          Expanded(
            child: Text(desc, style: GoogleFonts.inter(fontSize: 11, color: Colors.white54, height: 1.5)),
          ),
        ],
      ),
    );
  }
}
