import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloodhero/config/router/app_router.dart'; // Importa la instancia del router
import 'package:bloodhero/config/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(
    // ProviderScope sigue siendo esencial para que Riverpod funcione en toda la app
    const ProviderScope(child: MainApp()),
  );
}

// MainApp vuelve a ser un StatelessWidget simple
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // Pasa la instancia del router directamente
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
      title: 'BloodHero',
    );
  }
}
