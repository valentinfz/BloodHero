import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/domain/entities/appointment_detail_entity.dart';
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
      // .when para manejar los estados de carga, error y datos.
      body: appointmentDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
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
                ...appointment.reminders.map((reminder) => Text('• $reminder')),
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
                  onPressed: () => _handleCancel(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
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
}

void _handleReschedule(
  BuildContext context,
  AppointmentDetailEntity appointment,
) {
  context.pushNamed(
    AppointmentBookingDateScreen.name,
    extra: appointment.center,
  );
}

Future<void> _handleCancel(BuildContext context) async {
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
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Cancelar turno'),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tu turno fue cancelado.')),
    );
    if (!context.mounted) {
      return;
    }
    context.goNamed(CitasScreen.name);
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
