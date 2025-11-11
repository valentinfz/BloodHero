import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/location_provider.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  static const String name = 'preferences_screen';
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  bool emailNotifications = true;
  bool pushNotifications = true;
  bool smsNotifications = false;
  String selectedLanguageCode = 'es_AR';

  static const Map<String, String> _languageOptions = {
    'es_AR': 'Español (AR)',
    'es_MX': 'Español (MX)',
    'en_US': 'English (US)',
    'pt_BR': 'Português (BR)',
  };

  Future<void> _showLanguageSelector() async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const ListTile(
                title: Text(
                  'Elegí tu idioma',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              for (final entry in _languageOptions.entries)
                ListTile(
                  title: Text(entry.value),
                  trailing: selectedLanguageCode == entry.key
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () => Navigator.of(context).pop(entry.key),
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancelar'),
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );

    if (chosen != null && chosen != selectedLanguageCode) {
      setState(() => selectedLanguageCode = chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allowLocation = ref.watch(locationConsentProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Usar mi ubicación'),
            subtitle: const Text('Mostrar centros cercanos automáticamente'),
            value: allowLocation,
            onChanged: (value) => ref
                .read(locationConsentProvider.notifier)
                .setConsent(value),
          ),
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
            subtitle: Text(_languageOptions[selectedLanguageCode] ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Abrimos un selector simple para elegir idioma preferido.
              _showLanguageSelector();
            },
          ),
        ],
      ),
    );
  }
}
