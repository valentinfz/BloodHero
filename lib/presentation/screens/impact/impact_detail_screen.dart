import 'package:flutter/material.dart';

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
          children: const [
            Text(
              'Resumen del logro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Completaste los objetivos de este logro sumando tus donaciones y participación en alertas.'),
            SizedBox(height: 24),
            Text(
              'Próximo objetivo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Doná una vez más este mes para subir al siguiente nivel.'),
            Spacer(),
            FilledButton(
              onPressed: null,
              child: Text('Compartir logro'),
            ),
          ],
        ),
      ),
    );
  }
}
