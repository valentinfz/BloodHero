import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';
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
        padding: kScreenPadding,
        itemBuilder: (context, index) {
          final center = centers[index];
          final isSelected = center.name == selected;
          return InfoCard(
            title: center.name,
            body: [Text(center.address)],
            trailing: Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
            onTap: () => context.pushNamed(
              AppointmentBookingDateScreen.name,
              extra: center.name,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: kCardSpacing),
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
