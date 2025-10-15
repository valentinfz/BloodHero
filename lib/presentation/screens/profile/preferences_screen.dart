import 'package:flutter/material.dart';

class PreferencesScreen extends StatefulWidget {
  static const String name = 'preferences_screen';
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool emailNotifications = true;
  bool pushNotifications = true;
  bool smsNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificaciones por email'),
            value: emailNotifications,
            onChanged: (value) => setState(() => emailNotifications = value),
          ),
          SwitchListTile(
            title: const Text('Notificaciones push'),
            subtitle: const Text('Avisos inmediatos en tu dispositivo'),
            value: pushNotifications,
            onChanged: (value) => setState(() => pushNotifications = value),
          ),
          SwitchListTile(
            title: const Text('Recordatorios por SMS'),
            value: smsNotifications,
            onChanged: (value) => setState(() => smsNotifications = value),
          ),
          const Divider(),
          ListTile(
            title: const Text('Idioma'),
            subtitle: const Text('Español (AR)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Selección de idioma
            },
          ),
        ],
      ),
    );
  }
}
