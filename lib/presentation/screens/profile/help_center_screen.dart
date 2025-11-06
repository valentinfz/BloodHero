import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  static const String name = 'help_center_screen';
  const HelpCenterScreen({super.key});

  Future<void> _openSupportEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'soporte@bloodhero.com',
      queryParameters: {
        'subject': 'Consulta desde la app',
      },
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos abrir tu cliente de email. Intentá más tarde.'),
        ),
      );
    }
  }

  Future<void> _openSupportChat(BuildContext context) async {
    final messageController = TextEditingController();
    final presetMessages = <String>[
      'Tengo una duda sobre una donación programada.',
      'Quiero actualizar mis datos personales.',
      'Necesito reportar un problema con la app.',
    ];

    final sent = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escribinos tu consulta',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: presetMessages.map((preset) {
                  return ActionChip(
                    label: Text(preset),
                    onPressed: () {
                      messageController.text = preset;
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Mensaje',
                  border: OutlineInputBorder(),
                  hintText: 'Contanos en qué podemos ayudarte',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(false),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (messageController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text('Escribí un mensaje antes de enviar.'),
                          ),
                        );
                        return;
                      }
                      Navigator.of(sheetContext).pop(true);
                    },
                    child: const Text('Enviar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    messageController.dispose();

    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gracias. Un especialista se comunicará con vos a la brevedad.'),
        ),
      );
    }
  }

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
            onTap: () => _openSupportEmail(context),
          ),
          ListTile(
            leading: const Icon(Icons.chat_outlined),
            title: const Text('Chat en vivo'),
            subtitle: const Text('Disponible de 9 a 18 hs'),
            onTap: () => _openSupportChat(context),
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
