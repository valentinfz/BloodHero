import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import '../../../domain/entities/appointment_detail_entity.dart';
import '../../providers/appointments_provider.dart';
import 'appointment_booking_date_screen.dart';
// import 'citas_screen.dart';
// Se importa la entidad para poder usar el enum `AppointmentStatus`.
import '../../../domain/entities/appointment_entity.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  static const String name = 'appointment_detail_screen';
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentDetailAsync = ref.watch(
      appointmentDetailProvider(appointmentId),
    );

    final appointmentsState = ref.watch(appointmentsProvider);

    ref.listen<AppointmentsState>(appointmentsProvider, (_, next) {
      if (next.actionError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.actionError!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de cita')),
      body: appointmentDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error al cargar detalles: $error')),
        data: (appointment) {
          // --- Lógica para determinar si la cita ya pasó ---
          // Se parsea la fecha del detalle para compararla con la fecha actual.
          // NOTA: Esto es una simplificación. Una implementación robusta usaría
          // el `timestamp` original de Firestore para evitar problemas de formato.
          final isPastAppointment =
              _isAppointmentDatePast(appointment.date, appointment.time);
          // --- Fin de la lógica de fecha ---

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Turno confirmado',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _DetailRow(label: 'Centro', value: appointment.center),
                _DetailRow(label: 'Fecha', value: appointment.date),
                _DetailRow(label: 'Horario', value: appointment.time),
                _DetailRow(
                  label: 'Tipo de donación',
                  value: appointment.donationType,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Recordatorios',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Mostramos los recordatorios dinámicamente
                if (appointment.reminders.isEmpty)
                  const Text('No hay recordatorios específicos.')
                else
                  ...appointment.reminders.map(
                    (reminder) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text('• $reminder'),
                    ),
                  ),
                const Spacer(),

                // --- MODIFICACIÓN: Botones de acción dinámicos ---
                // Se muestran los botones según el estado de la cita.
                if (appointment.status == AppointmentStatus.scheduled) ...[
                  // Si la cita está agendada, se decide qué botones mostrar.
                  if (isPastAppointment)
                    // Si la cita ya pasó, se ofrece marcarla como completada.
                    AppButton.primary(
                      text: 'Marcar como completada',
                      onPressed: appointmentsState.isActing
                          ? null
                          : () => _handleLogDonation(
                                context,
                                ref,
                                appointmentId,
                                wasCompleted: true,
                              ),
                    )
                  else ...[
                    // Si la cita es futura, se ofrecen las acciones originales.
                    AppButton.primary(
                      text: 'Reprogramar turno',
                      onPressed: appointmentsState.isActing
                          ? null
                          : () => _handleReschedule(context, appointment),
                    ),
                    const SizedBox(height: 12),
                    AppButton.secondary(
                      text: 'Cancelar turno',
                      onPressed: appointmentsState.isActing
                          ? null
                          : () => _handleCancel(context, ref, appointmentId),
                    ),
                  ],
                ] else if (appointment.status == AppointmentStatus.completed) ...[
                  // Si la cita se completó, se muestra un mensaje.
                  const Center(
                    child: Text(
                      'Esta donación ya fue completada. ¡Gracias!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else ...[
                  // Para otros estados (cancelada, perdida), se muestra un mensaje informativo.
                  Center(
                    child: Text(
                      'Esta cita fue ${appointment.status.name}.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
                // Muestra un indicador de carga si se está ejecutando una acción.
                if (appointmentsState.isActing) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  //Funciones auxiliares para acciones:

  void _handleReschedule(
    BuildContext context,
    AppointmentDetailEntity appointment,
  ) {
    context.pushNamed(
      AppointmentBookingDateScreen.name,
      extra: {
        'centerId': appointment.centerId,
        'centerName': appointment.center,
        'appointmentId': appointment.id,
        'donationType': appointment.donationType,
        'initialDate': appointment.scheduledAt,
        'initialTime': appointment.time,
      },
    );
  }

  Future<void> _handleCancel(
    BuildContext context,
    WidgetRef ref,
    String appointmentId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar turno'),
        content: const Text(
          'Si cancelás, vas a liberar el turno reservado. ¿Querés continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Mantener turno'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar Cancelación'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(appointmentsProvider.notifier)
          .cancelAppointment(appointmentId);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tu turno fue cancelado.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    }
  }

  // --- NUEVA FUNCIÓN: Maneja el registro de la donación ---
  Future<void> _handleLogDonation(
    BuildContext context,
    WidgetRef ref,
    String appointmentId, {
    required bool wasCompleted,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar Donación'),
        content: const Text('¿Confirmás que realizaste esta donación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Aún no'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sí, la completé'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(appointmentsProvider.notifier).logDonation(
            appointmentId,
            wasCompleted: wasCompleted,
          );

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gracias por tu donación! Tu historial fue actualizado.'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    }
  }
  // --- FIN DE LA NUEVA FUNCIÓN ---

  // --- NUEVA FUNCIÓN AUXILIAR: Verifica si la fecha de la cita ya pasó ---
  bool _isAppointmentDatePast(String dateStr, String timeStr) {
    // Esta es una implementación simple y puede no ser robusta.
    // Asume formatos como "8 de Noviembre, 2025" y "10:30 hs".
    try {
      // Mapeo de meses en español a número.
      const monthMap = {
        'Enero': 1, 'Febrero': 2, 'Marzo': 3, 'Abril': 4, 'Mayo': 5, 'Junio': 6,
        'Julio': 7, 'Agosto': 8, 'Septiembre': 9, 'Octubre': 10, 'Noviembre': 11, 'Diciembre': 12,
      };

      final dateParts = dateStr.split(' ');
      final day = int.parse(dateParts[0]);
      final month = monthMap[dateParts[2].replaceAll(',', '')] ?? 1;
      final year = int.parse(dateParts[3]);

      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1].split(' ')[0]);

      final appointmentDateTime = DateTime(year, month, day, hour, minute);
      return appointmentDateTime.isBefore(DateTime.now());
    } catch (e) {
      // Si el parseo falla, se asume que no es pasada para evitar errores.
      return false;
    }
  }
  // --- FIN DE LA FUNCIÓN AUXILIAR ---
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
