import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/screens/home/home_screen.dart';
import 'package:bloodhero/presentation/widgets/primary_button.dart';

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
        physics: const NeverScrollableScrollPhysics(), // Para evitar deslizar manualmente
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Placeholder para la imagen/icono
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.shield_outlined, size: 100, color: Colors.grey[400]),
          ),
          const SizedBox(height: 50),
          Text(title, style: textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 10),
          Text(subtitle, style: textTheme.bodyMedium, textAlign: TextAlign.center),
          const Spacer(flex: 3),
          PrimaryButton(
            text: buttonText,
            onPressed: onPressed,
            backgroundColor: Colors.grey[300],
            foregroundColor: Colors.black87,
          ),
          const SizedBox(height: 20),
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