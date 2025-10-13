import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloodhero/config/router/app_router.dart';
import 'package:bloodhero/config/theme/app_theme.dart';

void main() {
  runApp(
    // ProviderScope es el widget que almacena el estado de todos los providers.
    // Es necesario para que Riverpod funcione.
    const ProviderScope(child: MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      title: 'BloodHero',
    );
  }
}
