import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/screens/splash/splash_screen.dart';
import 'package:bloodhero/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:bloodhero/presentation/screens/auth/login_screen.dart';
import 'package:bloodhero/presentation/screens/auth/register_screen.dart';
import 'package:bloodhero/presentation/screens/permissions/permissions_screen.dart';
import 'package:bloodhero/presentation/screens/home/home_screen.dart';
import 'package:bloodhero/presentation/screens/appointments/citas_screen.dart';

// GoRouter configuration
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: SplashScreen.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: OnboardingScreen.name,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      name: LoginScreen.name,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: RegisterScreen.name,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/permissions',
      name: PermissionsScreen.name,
      builder: (context, state) => const PermissionsScreen(),
    ),
    GoRoute(
      path: '/home',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    ),
    // --- AÑADIR NUEVA RUTA ---
    GoRoute(
      path: '/citas',
      name: CitasScreen.name,
      builder: (context, state) => const CitasScreen(),
    ),
  ],
);
