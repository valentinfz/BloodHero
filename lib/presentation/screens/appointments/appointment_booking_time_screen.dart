import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'package:bloodhero/presentation/widgets/shared/selectable_chip_group.dart';
import '../../providers/appointments_provider.dart';
import 'appointment_booking_confirm_screen.dart';

class AppointmentBookingTimeScreen extends ConsumerStatefulWidget {
  static const String name = 'appointment_booking_time_screen';
  final String centerName;
  final DateTime date;

  const AppointmentBookingTimeScreen({
    super.key,
    required this.centerName,
    required this.date,
  });

  @override
  AppointmentBookingTimeScreenState createState() =>
      AppointmentBookingTimeScreenState();
}

class AppointmentBookingTimeScreenState
    extends ConsumerState<AppointmentBookingTimeScreen> {
  // El estado de la seleccion del usuario se mantiene localmente
  Set<String> selectedTimes = {};

  @override
  Widget build(BuildContext context) {
    // Se crea el objeto para pasar al provider.family
    final params = AvailableTimesParams(
      centerName: widget.centerName,
      date: widget.date,
    );
    // Se observa el provider de horarios disponibles
    final availableTimesAsync = ref.watch(availableTimesProvider(params));

    return Scaffold(
      appBar: AppBar(title: const Text('Agendar donación · Horario')),
      body: Padding(
        padding: kScreenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Centro: ${widget.centerName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Fecha: ${widget.date.day}/${widget.date.month}/${widget.date.year}',
            ),
            const SizedBox(height: 24),
            const Text('Seleccioná un horario disponible'),
            const SizedBox(height: 12),
            // .when para manejar los estados del provider
            availableTimesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (times) => SelectableChipGroup<String>(
                options: times,
                selectedValues: selectedTimes,
                singleSelection: true,
                labelBuilder: (value) => value,
                // setState se usa para actualizar el estado local de la seleccion
                onSelectionChanged: (values) =>
                    setState(() => selectedTimes = values),
              ),
            ),
            const Spacer(),
            AppButton.primary(
              text: 'Confirmar horario',
              onPressed: selectedTimes.isEmpty
                  ? null
                  : () => context.pushNamed(
                      AppointmentBookingConfirmScreen.name,
                      extra: {
                        'center': widget.centerName,
                        'date': widget.date,
                        'time': selectedTimes.first,
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
