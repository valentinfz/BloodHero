import 'package:go_router/go_router.dart';
// Importamos TODAS las pantallas
import 'package:bloodhero/presentation/screens/splash/splash_screen.dart';
import 'package:bloodhero/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:bloodhero/presentation/screens/auth/login_screen.dart';
import 'package:bloodhero/presentation/screens/auth/register_screen.dart';
import 'package:bloodhero/presentation/screens/auth/forgot_password_screen.dart';
import 'package:bloodhero/presentation/screens/home/home_screen.dart';
import 'package:bloodhero/presentation/screens/centers/centers_screen.dart';
import 'package:bloodhero/presentation/screens/filters/filter_screen.dart';
import 'package:bloodhero/presentation/screens/centers/center_detail_screen.dart';
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
// Importamos las entidades/modelos necesarios para los 'extra'
import 'package:bloodhero/data/loaders/centers_loader.dart';
import 'package:bloodhero/domain/entities/center_entity.dart'; // Import CenterEntity

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
      path: '/forgot-password',
      name: ForgotPasswordScreen.name,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    // Ruta '/permissions' eliminada
    GoRoute(
      path: '/home',
      name: HomeScreen.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/centers',
      name: CenterScreen.name,
      builder: (context, state) => const CenterScreen(),
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
        final extra = state.extra;
        String? nameToPass;
        MapCenter?
        centerObjectToPass; // Variable para pasar el objeto si viene del mapa

        if (extra is CenterEntity) {
          // --- NUEVA CONDICIÓN ---
          // Si recibimos CenterEntity (desde centers_screen), extraemos el nombre
          // Y creamos un MapCenter temporal si la pantalla de detalle aún lo necesita
          // (idealmente CenterDetailScreen solo usaría el nombre para el provider)
          nameToPass = extra.name;
          centerObjectToPass = MapCenter(
            id: '',
            name: extra.name,
            address: extra.address,
            lat: extra.lat,
            lng: extra.lng,
            image: extra.image,
          );
        } else if (extra is MapCenter) {
          // Si recibimos MapCenter (quizás de una versión anterior o test), extraemos nombre y pasamos el objeto
          nameToPass = extra.name;
          centerObjectToPass = extra;
        } else if (extra is String?) {
          // Si recibimos String (o null), lo usamos directamente
          nameToPass = extra;
        }

        // Llamamos al constructor pasando ambos parámetros (centerName para el provider, center por compatibilidad)
        return CenterDetailScreen(
          centerName: nameToPass,
          center: centerObjectToPass,
        );
        // -----------------------
      },
    ),
    // Ruta '/center-reviews' comentada o eliminada
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
        String centerName = 'Hospital Central';
        String centerId = 'hospital_central';
        String? appointmentId;
        String? donationType;
        DateTime? initialDate;
        String? initialTime;

        final extra = state.extra;
        if (extra is Map<String, dynamic>) {
          centerName = extra['centerName'] as String? ?? centerName;
          centerId = extra['centerId'] as String? ?? centerId;
          appointmentId = extra['appointmentId'] as String?;
          donationType = extra['donationType'] as String?;
          final rawInitialDate = extra['initialDate'];
          if (rawInitialDate is DateTime) {
            initialDate = rawInitialDate;
          }
          initialTime = extra['initialTime'] as String?;
        } else if (extra is String?) {
          centerName = extra ?? centerName;
        }

        return AppointmentBookingDateScreen(
          centerId: centerId,
          centerName: centerName,
          appointmentId: appointmentId,
          donationType: donationType,
          initialScheduledDate: initialDate,
          initialTime: initialTime,
        );
      },
    ),
    GoRoute(
      path: '/appointments/book/time',
      name: AppointmentBookingTimeScreen.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        final center = data?['center'] as String? ?? 'Hospital Central';
        final date = data?['date'] as DateTime? ?? DateTime.now();
        final centerId =
            data?['centerId'] as String? ?? 'hospital_central';
        final appointmentId = data?['appointmentId'] as String?;
        final donationType = data?['donationType'] as String?;
        final initialTime = data?['initialTime'] as String?;
        return AppointmentBookingTimeScreen(
          centerId: centerId,
          centerName: center,
          date: date,
          appointmentId: appointmentId,
          donationType: donationType,
          initialTime: initialTime,
        );
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
        final appointmentId = data?['appointmentId'] as String?;
        return AppointmentBookingConfirmScreen(
          centerId: data?['centerId'] as String? ?? 'hospital_central',
          centerName: center,
          date: date,
          time: time,
          donationType: data?['donationType'] as String? ?? 'Sangre total',
          appointmentId: appointmentId,
        );
      },
    ),
    GoRoute(
      path: '/appointments/confirmation',
      name: AppointmentConfirmationScreen.name,
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        final center = data?['center'] as String? ?? 'Hospital Central';
        final date = data?['date'] as String? ?? '12/11/2025';
        final time = data?['time'] as String? ?? '10:30';
        final mode = data?['mode'] as String?;
        return AppointmentConfirmationScreen(
          center: center,
          date: date,
          time: time,
          isReschedule: mode == 'reschedule',
        );
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
