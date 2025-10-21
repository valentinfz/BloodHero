import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  static const String name = 'help_center_screen';
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = const [
      _Faq(
        '¿Quiénes pueden donar sangre?',
        'Personas mayores de 18 años, con buen estado de salud y más de 50kg.',
      ),
      _Faq(
        '¿Cada cuánto puedo donar?',
        'Cada 8 semanas para sangre total. Para plaquetas, cada 15 días.',
      ),
      _Faq(
        '¿Debo estar en ayunas?',
        'No. Se recomienda desayunar e hidratarse bien antes de donar.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Centro de ayuda')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'Preguntas frecuentes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...faqs.map(
            (faq) => ExpansionTile(
              title: Text(faq.question),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(faq.answer),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '¿Necesitás más ayuda?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: const Text('Enviar email'),
            subtitle: const Text('soporte@bloodhero.com'),
            onTap: () {
              // TODO: Enviar email
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_outlined),
            title: const Text('Chat en vivo'),
            subtitle: const Text('Disponible de 9 a 18 hs'),
            onTap: () {
              // TODO: abrir chat
            },
          ),
        ],
      ),
    );
  }
}

class _Faq {
  final String question;
  final String answer;

  const _Faq(this.question, this.answer);
}
