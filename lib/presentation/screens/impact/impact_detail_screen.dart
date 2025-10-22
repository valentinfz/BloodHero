import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

// REVISAR SI SE QUEDA O NO

class ImpactDetailScreen extends StatelessWidget {
  static const String name = 'impact_detail_screen';
  final String achievementTitle;

  const ImpactDetailScreen({super.key, required this.achievementTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(achievementTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen del logro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Completaste los objetivos de este logro sumando tus donaciones y participación en alertas.',
            ),
            const SizedBox(height: 24),
            const Text(
              'Próximo objetivo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Doná una vez más este mes para subir al siguiente nivel.'),
            const Spacer(),
            FilledButton(
              onPressed: () => Share.share(
                '¡Acabo de lograr $achievementTitle en BloodHero! Sumate y salvemos vidas juntos.',
                subject: 'Mi logro en BloodHero',
              ),
              child: const Text('Compartir logro'),
            ),
          ],
        ),
      ),
    );
  }
}
