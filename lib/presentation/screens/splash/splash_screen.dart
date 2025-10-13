import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/screens/onboarding/onboarding_screen.dart';

class SplashScreen extends StatelessWidget {
  static const String name = 'splash_screen';
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC62828),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                Image.asset('assets/images/bloodhero_logo.png', width: 150),

                const SizedBox(height: 20),
                const Text(
                  'BloodHero',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Spacer(flex: 3),
                ElevatedButton(
                  onPressed: () => context.goNamed(OnboardingScreen.name),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Comenzar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
