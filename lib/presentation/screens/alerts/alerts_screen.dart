import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'alert_detail_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';

class AlertsScreen extends StatelessWidget {
  static const String name = 'alerts_screen';
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = const [
      _AlertCardData('Hospital Central', 'O-', 'Urgente', '2 km'),
      _AlertCardData('Clínica Norte', 'A+', 'Dentro de 24 hs', '5 km'),
      _AlertCardData('Banco de Sangre Sur', 'B-', 'Dentro de 48 hs', '7 km'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas activas')),
      body: ListView.separated(
        padding: kScreenPadding,
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return InfoCard(
            title: alert.center,
            body: [
              Text('Tipo de sangre: ${alert.bloodType}'),
              Text('Estado: ${alert.status}'),
              Text('Distancia: ${alert.distance}'),
            ],
            trailing: const Icon(Icons.chevron_right),
            onTap: () =>
                context.pushNamed(AlertDetailScreen.name, extra: alert.center),
          );
        },
  separatorBuilder: (context, index) => const SizedBox(height: kCardSpacing),
        itemCount: alerts.length,
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}

class _AlertCardData {
  final String center;
  final String bloodType;
  final String status;
  final String distance;

  const _AlertCardData(this.center, this.bloodType, this.status, this.distance);
}
