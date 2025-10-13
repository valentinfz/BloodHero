import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/screens/auth/login_screen.dart';
import 'package:bloodhero/presentation/widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  static const String name = 'onboarding_screen';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  bool endReached = false;

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      final page = pageController.page ?? 0;
      if (!endReached && page >= (slides.length - 1.5)) {
        setState(() {
          endReached = true;
        });
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // Se añaden los iconos a la información de cada slide
  final slides = const <_SlideInfo>[
    _SlideInfo(
      'Bienvenido',
      'Encontrá centros y doná fácil',
      Icons.place_outlined,
    ),
    _SlideInfo(
      'Ranking',
      'Doná para subir de nivel',
      Icons.leaderboard_outlined,
    ),
    _SlideInfo('Impacto', 'Salvá vidas con tu aporte', Icons.favorite_border),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: pageController,
            children: slides
                .map(
                  (slideData) => _Slide(
                    title: slideData.title,
                    caption: slideData.caption,
                    icon: slideData.icon, // Se pasa el icono al widget
                  ),
                )
                .toList(),
          ),
          Positioned(
            bottom: 50,
            left: 30,
            right: 30,
            child: PrimaryButton(
              text: endReached ? 'Comenzar' : 'Siguiente',
              onPressed: () {
                if (endReached) {
                  context.goNamed(LoginScreen.name);
                } else {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final String title;
  final String caption;
  final IconData icon; // Se añade el icono como parámetro

  const _Slide({
    required this.title,
    required this.caption,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleLarge;
    final captionStyle = Theme.of(context).textTheme.bodySmall;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              // Se muestra el icono dentro del contenedor
              child: Icon(icon, size: 100, color: Colors.grey[400]),
            ),
            const SizedBox(height: 50),
            Text(title, style: titleStyle),
            const SizedBox(height: 10),
            Text(caption, style: captionStyle),
          ],
        ),
      ),
    );
  }
}

// Se añade el icono a la clase de datos
class _SlideInfo {
  final String title;
  final String caption;
  final IconData icon;
  const _SlideInfo(this.title, this.caption, this.icon);
}
