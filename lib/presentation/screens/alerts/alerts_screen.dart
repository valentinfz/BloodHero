import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import '../../providers/home_provider.dart';
import 'alert_detail_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';

class AlertsScreen extends ConsumerWidget {
  static const String name = 'alerts_screen';
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(nearbyAlertsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas activas')),
      body: alertsAsync.when(
        loading: () {
          debugPrint("AlertsScreen: Estado -> Cargando...");
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stack) {
          debugPrint("AlertsScreen: Estado -> Error: $error");
          debugPrintStack(stackTrace: stack, label: 'Error StackTrace');
          return Center(child: Text('Error al cargar alertas: $error'));
        },
        data: (alerts) {
          debugPrint(
            "AlertsScreen: Estado -> Datos recibidos (${alerts.length} alertas)",
          );

          if (alerts.isEmpty) {
            return const Center(
              child: Text('No hay alertas activas cerca tuyo.'),
            );
          }
          return ListView.separated(
            padding: kScreenPadding,
            itemBuilder: (context, index) {
              final alert =
                  alerts[index]; // Asegúrate de que `alerts` sea List<AlertEntity>
              return InfoCard(
                title: 'Se necesita ${alert.bloodType}',
                body: [
                  Text('Distancia: ${alert.distance}'),
                  Text('Vence: ${alert.expiration}'),
                ],
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  debugPrint("Navegando a detalle de alerta...");
                  // TODO: Idealmente, AlertEntity debería tener un ID o el nombre del centro
                  // para pasar información más útil a la pantalla de detalle.
                  context.pushNamed(
                    AlertDetailScreen.name,
                    extra:
                        'Centro de Ejemplo ${alert.bloodType}', // Pasa algo más específico
                  );
                },
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: kCardSpacing),
            itemCount: alerts.length,
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 3,
      ), // Índice correcto para Alertas
    );
  }
}
