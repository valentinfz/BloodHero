import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/screens/home/home_screen.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'package:bloodhero/presentation/widgets/shared/illustration_placeholder.dart';

class PermissionsScreen extends StatefulWidget {
  static const String name = 'permissions_screen';
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slides = <_PermissionSlideData>[
      _PermissionSlideData(
        title: '¿Podemos usar tu ubicación?',
        subtitle: 'Para mostrarte centros cercanos.',
        buttonText: 'Acepto',
        onPressed: () {
          // TODO: Implementar lógica para solicitar permiso de ubicación
          pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
      ),
      _PermissionSlideData(
        title: '¿Activar notificaciones?',
        subtitle: 'Recordatorios y alertas urgentes.',
        buttonText: 'Acepto',
        onPressed: () {
          // TODO: Implementar lógica para solicitar permiso de notificaciones
          context.goNamed(HomeScreen.name);
        },
      ),
    ];

    return Scaffold(
      body: PageView.builder(
        controller: pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Para evitar deslizar manualmente
        itemCount: slides.length,
        itemBuilder: (context, index) {
          final slide = slides[index];
          return _PermissionSlide(
            title: slide.title,
            subtitle: slide.subtitle,
            buttonText: slide.buttonText,
            onPressed: slide.onPressed,
          );
        },
      ),
    );
  }
}

class _PermissionSlide extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  const _PermissionSlide({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: kScreenPadding.copyWith(top: 40, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          IllustrationPlaceholder(size: 250, icon: Icons.shield_outlined),
          const SizedBox(height: kSectionSpacing * 2),
          Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: kSmallSpacing),
          Text(
            subtitle,
            style: textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 3),
          AppButton.primary(
            text: buttonText,
            onPressed: onPressed,
          ),
          const SizedBox(height: kCardSpacing),
        ],
      ),
    );
  }
}

// Clase de datos para organizar el contenido de cada slide
class _PermissionSlideData {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  _PermissionSlideData({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });
}
