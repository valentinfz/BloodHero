import 'package:flutter/material.dart';

class AppointmentDetailScreen extends StatelessWidget {
  static const String name = 'appointment_detail_screen';
  final String appointmentId;

  const AppointmentDetailScreen({super.key, required this.appointmentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de cita')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Turno confirmado',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const _DetailRow(label: 'Centro', value: 'Hospital Central'),
            const _DetailRow(label: 'Fecha', value: '12/11/2025'),
            const _DetailRow(label: 'Horario', value: '10:30 hs'),
            const _DetailRow(label: 'Tipo de donación', value: 'Sangre total'),
            const SizedBox(height: 24),
            const Text(
              'Recordatorios',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• Dormí al menos 6 horas la noche anterior.'),
            const Text('• Evitá consumir alcohol 24 hs antes.'),
            const Text('• Desayuná liviano antes de donar.'),
            const Spacer(),
            FilledButton(
              onPressed: () {
                // TODO: Implementar reprogramación
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Reprogramar turno'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                // TODO: Implementar cancelación
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Cancelar turno'),
            ),
          ],
        ),
      ),
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
