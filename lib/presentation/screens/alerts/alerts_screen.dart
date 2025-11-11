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
              final alert = alerts[index];
              final centerLabel =
                  (alert.centerName != null && alert.centerName!.isNotEmpty)
                      ? alert.centerName!
                      : 'Centro de donación';
              return InfoCard(
                title: centerLabel,
                body: [
                  Text('Tipo de sangre: ${alert.bloodType}'),
                  Text('Distancia: ${alert.distance}'),
                  Text('Vence: ${alert.expiration}'),
                ],
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  debugPrint("Navegando a detalle de alerta...");
          final identifier = (alert.centerName != null && alert.centerName!.isNotEmpty)
            ? alert.centerName!
            : alert.centerId ?? alert.id;
                  context.pushNamed(
                    AlertDetailScreen.name,
                    extra: identifier,
                  );
                },
              );
            },
      // separatorBuilder: (_, __) => const SizedBox(height: kCardSpacing),
      separatorBuilder: (context, _) =>
        const SizedBox(height: kCardSpacing),
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
