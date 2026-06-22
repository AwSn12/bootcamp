import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telpCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String _selectedRole = 'USER';

  @override
  void dispose() {
    for (final c in [_namaCtrl, _emailCtrl, _telpCtrl, _alamatCtrl, _usernameCtrl, _passwordCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      nama: _namaCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      noTelp: _telpCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
      role: _selectedRole,
    );
    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil! Silakan login.'), backgroundColor: AppTheme.success, behavior: SnackBarBehavior.floating),
      );
      context.go('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error ?? 'Registrasi gagal'), backgroundColor: AppTheme.error, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textDark, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.local_laundry_service, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                      children: const [
                        TextSpan(text: 'LAUNDRY'),
                        TextSpan(text: 'KU', style: TextStyle(color: AppTheme.primary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Dark sidebar info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Daftar Akun Baru', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Bebaskan diri Anda dari urusan cucian.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white54)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          CircleAvatar(backgroundColor: Colors.blueGrey.shade700, child: const Icon(Icons.person, color: Colors.white54, size: 18)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Andi Wijaya', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                                Text('"Layanan laundry terbaik!"', style: GoogleFonts.inter(fontSize: 11, color: Colors.white38, fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Card
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    Container(height: 4, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)))),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: _buildField('NAMA LENGKAP', _namaCtrl, 'Budi Santoso', Icons.person_outline, validator: (v) => (v?.length ?? 0) < 3 ? 'Min. 3 karakter' : null)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildField('EMAIL', _emailCtrl, 'budi@email.com', Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => !(v?.contains('@') ?? false) ? 'Email tidak valid' : null)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(child: _buildField('NO. TELEPON', _telpCtrl, '0812XXXXXXXX', Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => (v?.length ?? 0) < 10 ? 'Min. 10 digit' : null)),
                                const SizedBox(width: 12),
                                Expanded(child: _buildField('USERNAME', _usernameCtrl, 'budi_s', Icons.person_add_outlined, validator: (v) => (v?.length ?? 0) < 3 ? 'Min. 3 karakter' : null)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildField('ALAMAT LENGKAP', _alamatCtrl, 'Jl. Merdeka No. 123, Jakarta', Icons.location_on_outlined, validator: (v) => (v?.length ?? 0) < 5 ? 'Min. 5 karakter' : null),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: 'PASSWORD',
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textLight),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textLight),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v?.length ?? 0) < 6 ? 'Min. 6 karakter' : null,
                            ),
                            const SizedBox(height: 16),
                            const SizedBox(height: 8),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: auth.status == AuthStatus.loading ? null : _submit,
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: auth.status == AuthStatus.loading
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : Text('Daftar Sekarang', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Sudah punya akun? ', style: GoogleFonts.inter(color: AppTheme.textMid)),
                                GestureDetector(
                                  onTap: () => context.go('/login'),
                                  child: Text('Login di sini', style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textLight),
      ),
      validator: validator,
    );
  }
}
