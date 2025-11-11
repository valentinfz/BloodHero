import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
            onTap: () => _launchSupportEmail(context),
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

  Future<void> _launchSupportEmail(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri(
      scheme: 'mailto',
      path: 'soporte@bloodhero.com',
      queryParameters: const {
        'subject': 'Consulta desde la app BloodHero',
      },
    );

    if (!await launchUrl(uri)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el cliente de correo.'),
        ),
      );
    }
  }

  void _openSupportChat(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _SupportChatSheet(
          onMessageSent: (message) {
            Navigator.of(sheetContext).pop();
            messenger.showSnackBar(
              const SnackBar(
                content:
                    Text('¡Gracias! Un miembro del equipo te responderá pronto.'),
              ),
            );
          },
        );
      },
    );
  }
}

class _Faq {
  final String question;
  final String answer;

  const _Faq(this.question, this.answer);
}

class _SupportChatSheet extends StatefulWidget {
  final void Function(String message) onMessageSent;

  const _SupportChatSheet({required this.onMessageSent});

  @override
  State<_SupportChatSheet> createState() => _SupportChatSheetState();
}

class _SupportChatSheetState extends State<_SupportChatSheet> {
  final _controller = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomInset + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escribinos tu consulta',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '¿Cómo podemos ayudarte?',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSending
                  ? null
                  : () async {
                      final message = _controller.text.trim();
                      if (message.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Escribí un mensaje antes de enviarlo.'),
                          ),
                        );
                        return;
                      }

                      setState(() => _isSending = true);
                      await Future<void>.delayed(const Duration(milliseconds: 600));
                      widget.onMessageSent(message);
                    },
              child: _isSending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enviar mensaje'),
            ),
          ),
        ],
      ),
    );
  }
}
