import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'alert_detail_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';

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
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final alert = alerts[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                alert.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text('Tipo de sangre: ${alert.bloodType}'),
                  Text('Estado: ${alert.status}'),
                  Text('Distancia: ${alert.distance}'),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed(
                AlertDetailScreen.name,
                extra: alert.center,
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
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
