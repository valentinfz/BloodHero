import 'package:flutter/material.dart';

class AlertDetailScreen extends StatelessWidget {
  static const String name = 'alert_detail_screen';
  final String centerName;

  const AlertDetailScreen({super.key, required this.centerName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(centerName)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tipo de sangre requerido: O-',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Urgencia: Dentro de 12 horas'),
                  Text('Cantidad necesaria: 5 donaciones'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Se necesita sangre O- para pacientes en tratamiento de urgencia. Tu donación puede hacer la diferencia.',
            ),
            const SizedBox(height: 24),
            const Text('Contacto'),
            const SizedBox(height: 8),
            const Text('Teléfono: (011) 1234-5678'),
            const Text('Email: donaciones@hospital.com'),
            const Spacer(),
            FilledButton(
              onPressed: () {
                // TODO: Implementar respuesta a la alerta
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              child: const Text('Quiero ayudar'),
            ),
          ],
        ),
      ),
    );
  }
}
