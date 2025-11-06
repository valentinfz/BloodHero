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
    ref.listen<AppointmentActionsState>(
      appointmentActionsProvider,
      (previous, next) {
        final messenger = ScaffoldMessenger.of(context);
        final notifier = ref.read(appointmentActionsProvider.notifier);

        if (next.errorMessage != null &&
            next.errorMessage != previous?.errorMessage) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          notifier.clearMessages();
        }

        if (next.successMessage != null &&
            next.successMessage != previous?.successMessage) {
          final action = next.lastSuccessAction;
          messenger.showSnackBar(
            SnackBar(content: Text(next.successMessage!)),
          );

          if (action == AppointmentActionType.cancel && context.mounted) {
            context.goNamed(CitasScreen.name);
          } else if (action == AppointmentActionType.reschedule &&
              context.mounted) {
            final center = next.pendingRescheduleCenter;
            if (center != null) {
              context.pushNamed(
                AppointmentBookingDateScreen.name,
                extra: center,
              );
            }
          }

          notifier.clearMessages();
        }
      },
    );

    final actionState = ref.watch(appointmentActionsProvider);
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
                _DetailRow(label: 'Centro', value: appointment.centerName),
                _DetailRow(label: 'Fecha', value: appointment.dateLabel),
                _DetailRow(label: 'Horario', value: appointment.timeLabel),
                _DetailRow(
                  label: 'Tipo de donación',
                  value: appointment.donationType,
                ),
                _DetailRow(
                  label: 'Estado',
                  value: appointment.status.name,
                ),
                _DetailRow(
                  label: 'Verificación',
                  value:
                      appointment.verificationCompleted ? 'Completada' : 'Pendiente',
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
                  onPressed: actionState.isCancelling
                      ? null
                      : () => _handleReschedule(context, ref, appointment),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Reprogramar turno'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: actionState.isCancelling
                      ? null
                      : () => _handleCancel(
                            context,
                            ref,
                            appointment.id,
                          ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  child: actionState.isCancelling
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Cancelar turno'),
                ),
                if (!appointment.verificationCompleted) ...[
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: actionState.isVerifying
                        ? null
                        : () => _handleVerify(
                              context,
                              ref,
                              appointment.id,
                            ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: actionState.isVerifying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Validar código de donación'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  //Funciones auxiliares para acciones:

  Future<void> _handleReschedule(
    BuildContext context,
    WidgetRef ref,
    AppointmentDetailEntity appointment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reprogramar turno'),
        content: const Text(
          'Para reprogramar necesitamos liberar tu turno actual. '
          'Se cancelará la reserva y luego vas a elegir una nueva fecha.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar y reprogramar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await ref
        .read(appointmentActionsProvider.notifier)
        .cancelAppointmentForReschedule(
          appointmentId: appointment.id,
          centerName: appointment.centerName,
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
      await ref
          .read(appointmentActionsProvider.notifier)
          .cancelAppointment(appointmentId);
    }
  }

  Future<void> _handleVerify(
    BuildContext context,
    WidgetRef ref,
    String appointmentId,
  ) async {
    final controller = TextEditingController();
    String? code;

    try {
      code = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (dialogContext, setState) {
              final isValid = controller.text.trim().isNotEmpty;
              return AlertDialog(
                title: const Text('Ingresar código de verificación'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    labelText: 'Código de verificación',
                  ),
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() {}),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: isValid
                        ? () => Navigator.of(dialogContext)
                            .pop(controller.text.trim())
                        : null,
                    child: const Text('Verificar'),
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      controller.dispose();
    }

    if (code == null || code.isEmpty) {
      return;
    }

    await ref.read(appointmentActionsProvider.notifier).verifyDonationCode(
          appointmentId: appointmentId,
          code: code,
        );
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
