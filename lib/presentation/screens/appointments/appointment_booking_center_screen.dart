import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'appointment_booking_date_screen.dart';

class AppointmentBookingCenterScreen extends StatelessWidget {
  static const String name = 'appointment_booking_center_screen';
  final String? preselectedCenter;

  const AppointmentBookingCenterScreen({super.key, this.preselectedCenter});

  @override
  Widget build(BuildContext context) {
    final centers = const [
      _CenterOption('Hospital Central', 'Av. Siempre Viva 123'),
      _CenterOption('Banco de Sangre Norte', 'Calle Salud 456'),
      _CenterOption('Clínica San Martín', 'Boulevard Libertad 789'),
    ];

    final selected = preselectedCenter ?? centers.first.name;

    return Scaffold(
      appBar: AppBar(title: const Text('Agendar donación · Centro')),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final center = centers[index];
          final isSelected = center.name == selected;
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(center.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(center.address),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFFC62828))
                  : const Icon(Icons.circle_outlined),
              onTap: () => context.pushNamed(
                AppointmentBookingDateScreen.name,
                extra: center.name,
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: centers.length,
      ),
    );
  }
}

class _CenterOption {
  final String name;
  final String address;

  const _CenterOption(this.name, this.address);
}
