import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'appointment_confirmation_screen.dart';

class AppointmentBookingConfirmScreen extends StatelessWidget {
  static const String name = 'appointment_booking_confirm_screen';
  final String centerName;
  final DateTime date;
  final String time;

  const AppointmentBookingConfirmScreen({
    super.key,
    required this.centerName,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = '${date.day}/${date.month}/${date.year}';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar donación')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revisá los datos antes de confirmar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _SummaryRow(label: 'Centro', value: centerName),
            _SummaryRow(label: 'Fecha', value: formattedDate),
            _SummaryRow(label: 'Horario', value: time),
            _SummaryRow(label: 'Tipo de donación', value: 'Sangre total'),
            const SizedBox(height: 24),
            const Text('Recordá presentarte 15 minutos antes y llevar tu DNI.'),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => context.goNamed(
                AppointmentConfirmationScreen.name,
                extra: {
                  'center': centerName,
                  'date': formattedDate,
                  'time': time,
                },
              ),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Confirmar turno'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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
