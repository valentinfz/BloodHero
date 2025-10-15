import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'package:bloodhero/presentation/widgets/shared/selectable_chip_group.dart';
import 'appointment_booking_confirm_screen.dart';

class AppointmentBookingTimeScreen extends StatefulWidget {
  static const String name = 'appointment_booking_time_screen';
  final String centerName;
  final DateTime date;

  const AppointmentBookingTimeScreen({super.key, required this.centerName, required this.date});

  @override
  State<AppointmentBookingTimeScreen> createState() => _AppointmentBookingTimeScreenState();
}

class _AppointmentBookingTimeScreenState extends State<AppointmentBookingTimeScreen> {
  final List<String> availableTimes = ['09:00', '09:30', '10:00', '10:30', '11:00', '11:30'];
  Set<String> selectedTimes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar donación · Horario')),
      body: Padding(
        padding: kScreenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Centro: ${widget.centerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Fecha: ${widget.date.day}/${widget.date.month}/${widget.date.year}'),
            const SizedBox(height: 24),
            const Text('Seleccioná un horario disponible'),
            const SizedBox(height: 12),
            SelectableChipGroup<String>(
              options: availableTimes,
              selectedValues: selectedTimes,
              singleSelection: true,
              labelBuilder: (value) => value,
              onSelectionChanged: (values) => setState(() => selectedTimes = values),
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
