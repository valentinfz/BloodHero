import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'appointment_booking_time_screen.dart';

class AppointmentBookingDateScreen extends StatefulWidget {
  static const String name = 'appointment_booking_date_screen';
  final String centerName;

  const AppointmentBookingDateScreen({super.key, required this.centerName});

  @override
  State<AppointmentBookingDateScreen> createState() => _AppointmentBookingDateScreenState();
}

class _AppointmentBookingDateScreenState extends State<AppointmentBookingDateScreen> {
  DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendar donación · Fecha')),
      body: Padding(
        padding: kScreenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Centro: ${widget.centerName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              onDateChanged: (value) => setState(() => selectedDate = value),
            ),
            const Spacer(),
            AppButton.primary(
              text: 'Continuar con ${selectedDate.day}/${selectedDate.month}',
              onPressed: () => context.pushNamed(
                AppointmentBookingTimeScreen.name,
                extra: {'center': widget.centerName, 'date': selectedDate},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
