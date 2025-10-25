import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/appointment_detail_entity.dart';
import '../../providers/appointments_provider.dart';
import 'appointment_booking_date_screen.dart';
import 'citas_screen.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  static const String name = 'appointment_detail_screen';
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentDetailAsync = ref.watch(
      appointmentDetailProvider(appointmentId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de cita')),
      body: appointmentDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error al cargar detalles: $error')),
        data: (appointment) {
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
                FilledButton(
                  onPressed: () => _handleReschedule(context, appointment),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Reprogramar turno'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => _handleCancel(
                    context,
                    ref,
                  ), // Pasamos ref para posible lógica futura
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  child: const Text('Cancelar turno'),
                ),
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
      extra: appointment.center,
    );
    // TODO: Considerar si se debería cancelar la cita actual antes de reprogramar
  }

  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
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
      // TODO: Aquí iría la lógica para llamar a un método en un provider
      // que realmente cancele la cita en la base de datos.
      // Ejemplo: ref.read(appointmentsProvider.notifier).cancelAppointment(appointmentId);

      if (!context.mounted)
        return; // Buena práctica verificar `mounted` después de `await`
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu turno fue cancelado (simulado).')),
      );
      context.goNamed(CitasScreen.name);
    }
  }
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
