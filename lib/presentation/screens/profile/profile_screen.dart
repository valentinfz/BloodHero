import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/providers/home_provider.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/menu_button.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';
import 'preferences_screen.dart';
import 'security_screen.dart';
import 'help_center_screen.dart';
import 'checkin_qr_screen.dart';
import 'privacy_policy_screen.dart';
import '../history/history_screen.dart';

class ProfileScreen extends ConsumerWidget {
  static const String name = 'profile_screen';
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: userProfileAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text('Error al cargar el perfil: $error'),
            ),
            data: (user) => Column(
              children: [
                _UserInfoSection(
                  userName: user.name,
                  bloodType: user.bloodType,
                  ranking: user.ranking,
                ),
                const SizedBox(height: 32),
                MenuButton(
                  text: 'Editar perfil',
                  onPressed: () => context.pushNamed(EditProfileScreen.name),
                  isOutlined: true,
                ),
                const SizedBox(height: 16),
                MenuButton(
                  text: 'Historial de donaciones',
                  onPressed: () => context.pushNamed(HistoryScreen.name),
                  isOutlined: true,
                ),
                const SizedBox(height: 16),
                MenuButton(
                  text: 'Preferencias',
                  onPressed: () => context.pushNamed(PreferencesScreen.name),
                  isOutlined: true,
                ),
                const SizedBox(height: 16),
                MenuButton(
                  text: 'Seguridad',
                  onPressed: () => context.pushNamed(SecurityScreen.name),
                  isOutlined: true,
                ),
                const SizedBox(height: 16),
                MenuButton(
                  text: 'Centro de ayuda',
                  onPressed: () => context.pushNamed(HelpCenterScreen.name),
                  isOutlined: true,
                ),
                const SizedBox(height: 16),
                MenuButton(
                  text: 'Check-in QR',
                  onPressed: () => context.pushNamed(CheckInQrScreen.name),
                  isOutlined: true,
                ),
                const SizedBox(height: 16),
                MenuButton(
                  text: 'Política de privacidad',
                  onPressed: () => context.pushNamed(PrivacyPolicyScreen.name),
                  isOutlined: true,
                ),
                const SizedBox(height: 16),
                MenuButton(
                  text: 'Cerrar sesión',
                  onPressed: () {
                    context.goNamed(LoginScreen.name);
                  },
                  isOutlined: false,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
    );
  }
}

// Widgets internos de la pantalla de Perfil

class _UserInfoSection extends StatelessWidget {
  final String userName;
  final String bloodType;
  final String ranking;

  const _UserInfoSection({
    required this.userName,
    required this.bloodType,
    required this.ranking,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 60, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Text(
          userName,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Tipo Sangre: $bloodType',
          style: textTheme.titleMedium?.copyWith(
            color: const Color(0xFFC62828),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Ranking: $ranking',
          style: textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
        ),
      ],
    );
  }
}
