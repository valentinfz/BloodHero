import 'package:flutter/material.dart';

class CheckInQrScreen extends StatelessWidget {
  static const String name = 'checkin_qr_screen';
  const CheckInQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in QR')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Mostrá este código QR al llegar al centro para agilizar tu registro.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text('QR Placeholder'),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                // TODO: Descargar código QR
              },
              icon: const Icon(Icons.download),
              label: const Text('Descargar código'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                // TODO: Compartir código QR
              },
              icon: const Icon(Icons.share),
              label: const Text('Compartir'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
