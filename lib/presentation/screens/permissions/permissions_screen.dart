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
        subtitle: 'Para mostrarte centros cercanos y calcular la distancia estimada al donar.',
        primaryButtonText: 'Permitir ubicación',
        onPrimaryPressed: () {
          // TODO: Implementar lógica para solicitar permiso de ubicación
          pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        secondaryButtonText: 'No por ahora',
        onSecondaryPressed: () {
          pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        helperText: 'Podrás activarla más adelante desde Ajustes o la sección de permisos de la app.',
      ),
      _PermissionSlideData(
        title: '¿Activar notificaciones?',
        subtitle: 'Recordatorios de turnos y alertas importantes para tus donaciones.',
        primaryButtonText: 'Activar notificaciones',
        onPrimaryPressed: () {
          // TODO: Implementar lógica para solicitar permiso de notificaciones
          context.goNamed(HomeScreen.name);
        },
        secondaryButtonText: 'Quizás más tarde',
        onSecondaryPressed: () => context.goNamed(HomeScreen.name),
        helperText: 'Si cambiás de idea podés activarlas luego desde la configuración del sistema.',
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
            primaryButtonText: slide.primaryButtonText,
            onPrimaryPressed: slide.onPrimaryPressed,
            secondaryButtonText: slide.secondaryButtonText,
            onSecondaryPressed: slide.onSecondaryPressed,
            helperText: slide.helperText,
          );
        },
      ),
    );
  }
}

class _PermissionSlide extends StatelessWidget {
  final String title;
  final String subtitle;
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final String? helperText;

  const _PermissionSlide({
    required this.title,
    required this.subtitle,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.helperText,
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
          AppButton.primary(text: primaryButtonText, onPressed: onPrimaryPressed),
          if (secondaryButtonText != null) ...[
            const SizedBox(height: kCardSpacing),
            AppButton.secondary(
              text: secondaryButtonText!,
              onPressed: onSecondaryPressed,
            ),
          ],
          if (helperText != null) ...[
            const SizedBox(height: kCardSpacing),
            Text(
              helperText!,
              style: textTheme.bodySmall?.copyWith(color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
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
  final String primaryButtonText;
  final VoidCallback onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final String? helperText;

  _PermissionSlideData({
    required this.title,
    required this.subtitle,
    required this.primaryButtonText,
    required this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.helperText,
  });
}
