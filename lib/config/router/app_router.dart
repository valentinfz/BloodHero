import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/screens/splash/splash_screen.dart';
import 'package:bloodhero/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:bloodhero/presentation/screens/auth/login_screen.dart';
import 'package:bloodhero/presentation/screens/auth/register_screen.dart';
import 'package:bloodhero/presentation/screens/auth/complete_profile_screen.dart';
import 'package:bloodhero/presentation/screens/auth/forgot_password_screen.dart';
import 'package:bloodhero/presentation/screens/permissions/permissions_screen.dart';
import 'package:bloodhero/presentation/screens/home/home_screen.dart';
import 'package:bloodhero/presentation/screens/map/map_screen.dart';
import 'package:bloodhero/presentation/screens/filters/filter_screen.dart';
import 'package:bloodhero/presentation/screens/centers/center_detail_screen.dart';
import 'package:bloodhero/presentation/screens/centers/center_reviews_screen.dart';
import 'package:bloodhero/presentation/screens/appointments/appointment_booking_center_screen.dart';
import 'package:bloodhero/presentation/screens/appointments/appointment_booking_date_screen.dart';
import 'package:bloodhero/presentation/screens/appointments/appointment_booking_time_screen.dart';
import 'package:bloodhero/presentation/screens/appointments/appointment_booking_confirm_screen.dart';
import 'package:bloodhero/presentation/screens/appointments/appointment_confirmation_screen.dart';
import 'package:bloodhero/presentation/screens/appointments/appointment_detail_screen.dart';
import 'package:bloodhero/presentation/screens/appointments/citas_screen.dart';
import 'package:bloodhero/presentation/screens/alerts/alerts_screen.dart';
import 'package:bloodhero/presentation/screens/alerts/alert_detail_screen.dart';
import 'package:bloodhero/presentation/screens/impact/impact_screen.dart';
import 'package:bloodhero/presentation/screens/impact/impact_detail_screen.dart';
import 'package:bloodhero/presentation/screens/history/history_screen.dart';
import 'package:bloodhero/presentation/screens/profile/profile_screen.dart';
import 'package:bloodhero/presentation/screens/profile/edit_profile_screen.dart';
import 'package:bloodhero/presentation/screens/profile/preferences_screen.dart';
import 'package:bloodhero/presentation/screens/profile/security_screen.dart';
import 'package:bloodhero/presentation/screens/profile/help_center_screen.dart';
import 'package:bloodhero/presentation/screens/profile/checkin_qr_screen.dart';
import 'package:bloodhero/presentation/screens/profile/privacy_policy_screen.dart';

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
      path: '/complete-profile',
      name: CompleteProfileScreen.name,
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: ForgotPasswordScreen.name,
      builder: (context, state) => const ForgotPasswordScreen(),
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
    GoRoute(
      path: '/map',
      name: MapScreen.name,
      builder: (context, state) => const MapScreen(),
    ),
    GoRoute(
      path: '/filters',
      name: FilterScreen.name,
      builder: (context, state) => const FilterScreen(),
    ),
    GoRoute(
      path: '/center-detail',
      name: CenterDetailScreen.name,
      builder: (context, state) {
        final centerName = state.extra as String?;
        return CenterDetailScreen(centerName: centerName);
      },
    ),
    GoRoute(
      path: '/center-reviews',
      name: CenterReviewsScreen.name,
      builder: (context, state) {
        final centerName = state.extra as String?;
        return CenterReviewsScreen(centerName: centerName);
      },
    ),
    GoRoute(
      path: '/appointments/book/center',
      name: AppointmentBookingCenterScreen.name,
      builder: (context, state) {
        final preselected = state.extra as String?;
        return AppointmentBookingCenterScreen(preselectedCenter: preselected);
      },
    ),
    GoRoute(
      path: '/appointments/book/date',
      name: AppointmentBookingDateScreen.name,
      builder: (context, state) {
        final centerName = state.extra as String? ?? 'Hospital Central';
        return AppointmentBookingDateScreen(centerName: centerName);
      },
    ),
    GoRoute(
      path: '/appointments/book/time',
      name: AppointmentBookingTimeScreen.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        final center = data?['center'] as String? ?? 'Hospital Central';
        final date = data?['date'] as DateTime? ?? DateTime.now();
        return AppointmentBookingTimeScreen(centerName: center, date: date);
      },
    ),
    GoRoute(
      path: '/appointments/book/confirm',
      name: AppointmentBookingConfirmScreen.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        final center = data?['center'] as String? ?? 'Hospital Central';
        final date = data?['date'] as DateTime? ?? DateTime.now();
        final time = data?['time'] as String? ?? '09:00';
        return AppointmentBookingConfirmScreen(centerName: center, date: date, time: time);
      },
    ),
    GoRoute(
      path: '/appointments/confirmation',
      name: AppointmentConfirmationScreen.name,
      builder: (context, state) {
        final data = state.extra as Map<String, String>?;
        final center = data?['center'] ?? 'Hospital Central';
        final date = data?['date'] ?? '12/11/2025';
        final time = data?['time'] ?? '10:30';
        return AppointmentConfirmationScreen(center: center, date: date, time: time);
      },
    ),
    GoRoute(
      path: '/citas',
      name: CitasScreen.name,
      builder: (context, state) => const CitasScreen(),
    ),
    GoRoute(
      path: '/appointments/detail',
      name: AppointmentDetailScreen.name,
      builder: (context, state) {
        final appointmentId = state.extra as String? ?? '1';
        return AppointmentDetailScreen(appointmentId: appointmentId);
      },
    ),
    GoRoute(
      path: '/alerts',
      name: AlertsScreen.name,
      builder: (context, state) => const AlertsScreen(),
    ),
    GoRoute(
      path: '/alerts/detail',
      name: AlertDetailScreen.name,
      builder: (context, state) {
        final centerName = state.extra as String? ?? 'Centro de donación';
        return AlertDetailScreen(centerName: centerName);
      },
    ),
    GoRoute(
      path: '/impact',
      name: ImpactScreen.name,
      builder: (context, state) => const ImpactScreen(),
    ),
    GoRoute(
      path: '/impact/detail',
      name: ImpactDetailScreen.name,
      builder: (context, state) {
        final achievement = state.extra as String? ?? 'Logro';
        return ImpactDetailScreen(achievementTitle: achievement);
      },
    ),
    GoRoute(
      path: '/history',
      name: HistoryScreen.name,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: ProfileScreen.name,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/edit',
      name: EditProfileScreen.name,
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/profile/preferences',
      name: PreferencesScreen.name,
      builder: (context, state) => const PreferencesScreen(),
    ),
    GoRoute(
      path: '/profile/security',
      name: SecurityScreen.name,
      builder: (context, state) => const SecurityScreen(),
    ),
    GoRoute(
      path: '/profile/help',
      name: HelpCenterScreen.name,
      builder: (context, state) => const HelpCenterScreen(),
    ),
    GoRoute(
      path: '/profile/checkin',
      name: CheckInQrScreen.name,
      builder: (context, state) => const CheckInQrScreen(),
    ),
    GoRoute(
      path: '/profile/privacy',
      name: PrivacyPolicyScreen.name,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
  ],
);
