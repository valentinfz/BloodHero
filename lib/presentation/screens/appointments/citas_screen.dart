import 'package:flutter/material.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';

class CitasScreen extends StatelessWidget {
  static const String name = 'citas_screen';
  const CitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas'),
      ),
      body: const Center(
        child: Text('Aquí se mostrará la lista de tus citas.'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}