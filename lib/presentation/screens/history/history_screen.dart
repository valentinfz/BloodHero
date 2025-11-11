import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/history_provider.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
// Se importa la entidad para poder usar el enum `AppointmentStatus`.
import '../../../domain/entities/appointment_entity.dart';

class HistoryScreen extends ConsumerWidget {
  static const String name = 'history_screen';
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(donationHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de donaciones')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error al cargar historial: $error')),
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Text('Aún no tienes donaciones registradas.'),
            );
          }

          // --- COMENTARIO: Filtrado de historial ---
          // Se filtran las citas que aún están 'agendadas' para no mostrarlas
          // en el historial, ya que este solo debe contener citas pasadas.
          final pastAppointments = history
              .where((item) => item.status != AppointmentStatus.scheduled)
              .toList();

          if (pastAppointments.isEmpty) {
            return const Center(
              child: Text('No hay citas completadas o canceladas aún.'),
            );
          }
          // --- FIN DEL COMENTARIO ---

          return ListView.separated(
            padding: kScreenPadding,
            itemBuilder: (context, index) {
              final item = pastAppointments[index];
              // --- COMENTARIO: Se usan helpers para determinar el estilo ---
              // En lugar de un if/else con `wasCompleted`, se usan funciones
              // que devuelven el color, ícono y texto según el `AppointmentStatus`.
              final icon = _getIconForStatus(item.status);
              final backgroundColor = _getBackgroundColorForStatus(item.status);
              final foregroundColor = _getForegroundColorForStatus(item.status);
              final statusText = _getTextForStatus(item.status);
              // --- FIN DEL COMENTARIO ---

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kCardBorderRadius),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: backgroundColor,
                    child: Icon(
                      icon,
                      color: foregroundColor,
                    ),
                  ),
                  title: Text('${item.date} · ${item.type}'),
                  subtitle: Text(item.center),
                  trailing: Text(
                    statusText,
                    style: TextStyle(
                      color: foregroundColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
      // separatorBuilder: (_, __) => const SizedBox(height: kCardSpacing),
      separatorBuilder: (context, _) =>
        const SizedBox(height: kCardSpacing),
            itemCount: pastAppointments.length,
          );
        },
      ),
    );
  }

  // --- COMENTARIO: Funciones Helper para Estilo ---
  // Estas funciones ayudan a mantener el widget `build` más limpio y legible.
  // Cada una se encarga de un aspecto visual específico basado en el estado.

  IconData _getIconForStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return Icons.check_circle_outline;
      case AppointmentStatus.cancelled:
        return Icons.cancel_outlined;
      case AppointmentStatus.missed:
        return Icons.highlight_off; // Ícono para ausencias
      case AppointmentStatus.scheduled:
        return Icons.schedule_outlined; // No debería aparecer, pero es un fallback
    }
  }

  Color _getBackgroundColorForStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return Colors.green.shade100;
      case AppointmentStatus.cancelled:
        return Colors.red.shade100;
      case AppointmentStatus.missed:
        return Colors.orange.shade100;
      case AppointmentStatus.scheduled:
        return Colors.blue.shade100;
    }
  }

  Color _getForegroundColorForStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return Colors.green.shade800;
      case AppointmentStatus.cancelled:
        return Colors.red.shade800;
      case AppointmentStatus.missed:
        return Colors.orange.shade800;
      case AppointmentStatus.scheduled:
        return Colors.blue.shade800;
    }
  }

  String _getTextForStatus(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.completed:
        return 'Completada';
      case AppointmentStatus.cancelled:
        return 'Cancelada';
      case AppointmentStatus.missed:
        return 'Ausente';
      case AppointmentStatus.scheduled:
        return 'Agendada';
    }
  }
  // --- FIN DE FUNCIONES HELPER ---
}
