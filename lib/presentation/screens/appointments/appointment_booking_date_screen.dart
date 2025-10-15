import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
        padding: const EdgeInsets.all(24),
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
            FilledButton(
              onPressed: () => context.pushNamed(
                AppointmentBookingTimeScreen.name,
                extra: {'center': widget.centerName, 'date': selectedDate},
              ),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              child: Text('Continuar con ${selectedDate.day}/${selectedDate.month}'),
            ),
          ],
        ),
      ),
    );
  }
}
