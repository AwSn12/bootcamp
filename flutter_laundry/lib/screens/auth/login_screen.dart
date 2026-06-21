import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_identifierCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (ok && auth.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selamat datang, ${auth.user!.nama}!'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (auth.user!.isAdmin) {
        context.go('/admin');
      } else if (auth.user!.isKurir) {
        context.go('/kurir');
      } else {
        context.go('/dashboard');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login gagal'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Icon(Icons.local_laundry_service, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              Text('Login Akun', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textDark)),
              const SizedBox(height: 8),
              Text('Masuk untuk mengelola laundry Anda', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textMid)),
              const SizedBox(height: 32),

              // Card Form
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                ),
                child: Column(
                  children: [
                    // Blue accent line
                    Container(height: 4, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: const BorderRadius.vertical(top: Radius.circular(24)))),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('EMAIL ATAU USERNAME'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _identifierCtrl,
                              decoration: InputDecoration(
                                hintText: 'Masukan Akun Gmail Atau Username Anda',
                                prefixIcon: const Icon(Icons.email_outlined, color: AppTheme.textLight),
                              ),
                              validator: (v) => (v?.length ?? 0) < 3 ? 'Minimal 3 karakter' : null,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('PASSWORD'),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textLight),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textLight),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),
                              validator: (v) => (v?.length ?? 0) < 6 ? 'Password minimal 6 karakter' : null,
                            ),
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
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('Masuk', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.arrow_forward, size: 18),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun? ', style: GoogleFonts.inter(color: AppTheme.textMid)),
                  GestureDetector(
                    onTap: () => context.push('/register'),
                    child: Text('Daftar Sekarang', style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppTheme.textMid, letterSpacing: 1.5));
  }
}
