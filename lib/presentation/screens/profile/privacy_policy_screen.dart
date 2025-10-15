import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const String name = 'privacy_policy_screen';
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sections = const [
      _PolicySection(
        title: '1. Información que recopilamos',
        body:
            'Recopilamos datos personales que brindás voluntariamente, como nombre, email, historial de donaciones y preferencias de comunicación.',
      ),
      _PolicySection(
        title: '2. Uso de la información',
        body:
            'Utilizamos tus datos para gestionar tus turnos, enviarte recordatorios y mostrarte alertas relevantes cercanas a tu ubicación.',
      ),
      _PolicySection(
        title: '3. Compartir información',
        body:
            'No compartimos tus datos con terceros sin tu consentimiento, salvo centros de donación con los que agendes turnos.',
      ),
      _PolicySection(
        title: '4. Tus derechos',
        body:
            'Podés solicitar acceso, actualización o eliminación de tus datos contactándonos en privacidad@bloodhero.com.',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Política de privacidad')),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final section = sections[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(section.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(section.body),
            ],
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 20),
        itemCount: sections.length,
      ),
    );
  }
}

class _PolicySection {
  final String title;
  final String body;

  const _PolicySection({required this.title, required this.body});
}
