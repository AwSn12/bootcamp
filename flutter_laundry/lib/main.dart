import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/maps_provider.dart';
import 'providers/lbs_provider.dart';

// Screens
import 'screens/landing/landing_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user/user_dashboard_screen.dart';
import 'screens/user/order_screen.dart';
import 'screens/user/payment_screen.dart';
import 'screens/user/tracking_screen.dart';
import 'screens/user/laundry_terdekat_screen.dart';
import 'screens/user/detail_laundry_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/kurir/kurir_dashboard_screen.dart';
import 'data/models/mitra_laundry_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id', null);
  runApp(const LaundryApp());
}

class LaundryApp extends StatefulWidget {
  const LaundryApp({super.key});

  @override
  State<LaundryApp> createState() => _LaundryAppState();
}

class _LaundryAppState extends State<LaundryApp> {
  late final AuthProvider _authProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider()..checkAuth();

    // ─── Router dengan refreshListenable ────────────────────────────────────
    // Menggunakan AuthProvider sebagai refreshListenable agar redirect
    // dipanggil ulang setiap kali status auth berubah (tanpa race condition
    // dengan async StorageService).
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: _authProvider,
      redirect: (context, state) {
        final status = _authProvider.status;
        final loc = state.uri.toString();

        // Masih loading sesi — jangan redirect dulu
        if (status == AuthStatus.initial) return null;

        final isLoggedIn = status == AuthStatus.authenticated;
        final user = _authProvider.user;

        // Sudah login tapi ke halaman auth → redirect ke dashboard sesuai role
        if (isLoggedIn && (loc == '/login' || loc == '/register' || loc == '/')) {
          if (user?.isAdmin ?? false) return '/admin';
          if (user?.isKurir ?? false) return '/kurir';
          return '/dashboard';
        }

        // Belum login tapi ke halaman protected
        final protectedRoutes = [
          '/dashboard',
          '/order',
          '/admin',
          '/kurir',
          '/laundry-terdekat',
          '/tracking',
        ];
        if (!isLoggedIn && protectedRoutes.any((r) => loc.startsWith(r))) {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (ctx, state) => const LandingScreen()),
        GoRoute(path: '/login', builder: (ctx, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (ctx, state) => const RegisterScreen()),
        GoRoute(path: '/dashboard', builder: (ctx, state) => const UserDashboardScreen()),
        GoRoute(path: '/order', builder: (ctx, state) => const OrderScreen()),
        GoRoute(
          path: '/tracking/:kode',
          builder: (ctx, state) => TrackingScreen(kodeOrder: state.pathParameters['kode'] ?? ''),
        ),
        GoRoute(
          path: '/payment/:kode',
          builder: (ctx, state) => PaymentScreen(
            kodeOrder: state.pathParameters['kode'] ?? '',
            metodeAwal: state.uri.queryParameters['method'] ?? 'DOMPET DIGITAL',
          ),
        ),
        GoRoute(path: '/admin', builder: (ctx, state) => const AdminDashboardScreen()),
        GoRoute(path: '/kurir', builder: (ctx, state) => const KurirDashboardScreen()),

        // ─── LBS Routes ────────────────────────────────────────────────────
        GoRoute(
          path: '/laundry-terdekat',
          builder: (ctx, state) => const LaundryTerdekatScreen(),
        ),
        GoRoute(
          path: '/laundry-terdekat/:id',
          builder: (ctx, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final mitra = extra?['mitra'] as MitraLaundryModel?;
            final userLat = extra?['userLat'] as double?;
            final userLng = extra?['userLng'] as double?;

            if (mitra == null) return const LaundryTerdekatScreen();
            return DetailLaundryScreen(
              mitra: mitra,
              userLat: userLat,
              userLng: userLng,
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider sudah dibuat di initState — gunakan .value agar sama instance
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => MapsProvider()),
        ChangeNotifierProvider(create: (_) => LbsProvider()),
      ],
      child: MaterialApp.router(
        title: 'LaundryKU',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
