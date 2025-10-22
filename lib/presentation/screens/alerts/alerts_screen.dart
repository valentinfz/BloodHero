import 'package:bloodhero/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'alert_detail_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';

class AlertsScreen extends ConsumerWidget {
  static const String name = 'alerts_screen';
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Se observa el nearbyAlertsProvider que ya existía en home_providers
    final alertsAsync = ref.watch(nearbyAlertsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Alertas activas')),
      // .when para manejar los estados
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (alerts) {
          // Si no hay alertas, mostramos un mensaje
          if (alerts.isEmpty) {
            return const Center(
              child: Text('No hay alertas activas cerca tuyo.'),
            );
          }
          // Si hay alertas, construimos la lista
          return ListView.separated(
            padding: kScreenPadding,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              // Usamos AlertEntity directamente
              return InfoCard(
                title:
                    'Se necesita ${alert.bloodType}', // Título más descriptivo
                body: [
                  Text('Distancia: ${alert.distance}'),
                  Text('Vence: ${alert.expiration}'),
                  // Podríamos añadir el centro si lo tuviéramos en AlertEntity
                ],
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(
                  AlertDetailScreen.name,
                  extra:
                      'Centro de Ejemplo', // TODO: Pasar el nombre real del centro
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: kCardSpacing),
            itemCount: alerts.length,
          );
        },
      ),
      // TODO: Ajustar el currentIndex si es necesario para esta pantalla
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: 0,
      ), // Asumo 0 por ahora
    );
  }
}
