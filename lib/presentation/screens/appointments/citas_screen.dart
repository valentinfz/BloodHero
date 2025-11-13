import 'package:bloodhero/presentation/providers/appointments_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';
import 'appointment_booking_date_screen.dart';
import 'appointment_detail_screen.dart';
import '../../../domain/entities/appointment_entity.dart';

class CitasScreen extends ConsumerWidget {
  static const String name = 'citas_screen';
  const CitasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsState = ref.watch(appointmentsProvider);
    final appointmentsAsync = appointmentsState.appointments;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Citas')),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(appointmentsProvider.notifier).loadAppointments(),
        child: appointmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: kScreenPadding,
              child: Text('Error al cargar las citas: $error'),
            ),
          ),
          data: (appointments) {
            if (appointments.isEmpty) {
              return const Center(
                child: Text('Aún no tienes citas agendadas.'),
              );
            }
            return ListView.separated(
              padding: kScreenPadding,
              itemBuilder: (context, index) {
                final appointment = appointments[index];

                IconData statusIcon;
                Color statusColor;

                switch (appointment.status) {
                  case AppointmentStatus.completed:
                    statusIcon = Icons.check_circle;
                    statusColor = Colors.green;
                    break;
                  case AppointmentStatus.cancelled:
                    statusIcon = Icons.cancel;
                    statusColor = Colors.red;
                    break;
                  case AppointmentStatus.missed:
                    statusIcon = Icons.highlight_off;
                    statusColor = Colors.orange;
                    break;
                  case AppointmentStatus.scheduled:
                    statusIcon = Icons.schedule;
                    statusColor = Theme.of(context).colorScheme.primary;
                    break;
                  // default:
                  //   statusIcon = Icons.schedule;
                  //   statusColor = Theme.of(context).colorScheme.primary;
                  //   break;
                }

                return InfoCard(
                  title: '${appointment.date} · ${appointment.time}',
                  body: [Text(appointment.location)],
                  leading: Icon(statusIcon, color: statusColor),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<_AppointmentMenuAction>(
                        tooltip: 'Acciones',
                        enabled: !appointmentsState.isActing,
                        onSelected: (action) => _handleMenuAction(
                          context,
                          ref,
                          appointment,
                          action,
                        ),
                        itemBuilder: (context) => const [
                          // Se eliminó el PopupMenuItem para 'Ver detalle'
                          PopupMenuItem(
                            value: _AppointmentMenuAction.reschedule,
                            child: Text('Reprogramar'),
                          ),
                          PopupMenuItem(
                            value: _AppointmentMenuAction.cancel,
                            child: Text('Cancelar turno'),
                          ),
                        ],
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  // El onTap principal sigue llevando a los detalles
                  onTap: () => context.pushNamed(
                    AppointmentDetailScreen.name,
                    extra: appointment.id,
                  ),
                );
              },
              separatorBuilder: (context, index) =>
                  const SizedBox(height: kCardSpacing),
              itemCount: appointments.length,
            );
          },
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}

// Se eliminó 'view' de la enumeración
enum _AppointmentMenuAction { reschedule, cancel }

void _handleMenuAction(
  BuildContext context,
  WidgetRef ref,
  AppointmentEntity appointment,
  _AppointmentMenuAction action,
) {
  switch (action) {
    // Se eliminó el case para 'view'
    case _AppointmentMenuAction.reschedule:
      _startReschedule(context, appointment);
      return;
    case _AppointmentMenuAction.cancel:
      _confirmCancellation(context, ref, appointment.id);
      return;
  }
}

void _startReschedule(BuildContext context, AppointmentEntity appointment) {
  if (appointment.scheduledAt == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No pudimos cargar la fecha actual del turno.'),
      ),
    );
    return;
  }

  context.pushNamed(
    AppointmentBookingDateScreen.name,
    extra: {
      'centerId': appointment.centerId,
      'centerName': appointment.location,
      'appointmentId': appointment.id,
      'donationType': appointment.donationType,
      'initialDate': appointment.scheduledAt,
      'initialTime': appointment.time,
    },
  );
}

Future<void> _confirmCancellation(
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
          child: const Text('Confirmar cancelación'),
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
    }
  }
}
