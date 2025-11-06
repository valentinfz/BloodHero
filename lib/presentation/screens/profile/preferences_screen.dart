import 'package:bloodhero/presentation/providers/preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  static const String name = 'preferences_screen';
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  void _showFeedback(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _openLanguageSelector(String currentCode) async {
    final selectedCode = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Seleccioná tu idioma preferido',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ...preferenceLanguageOptions.map((option) {
                return RadioListTile<String>(
                  value: option.code,
                  groupValue: currentCode,
                  title: Text(option.label),
                  onChanged: (value) {
                    Navigator.of(sheetContext).pop(value);
                  },
                );
              }),
              Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Cancelar'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedCode == null || selectedCode == currentCode) {
      return;
    }

    ref.read(preferencesProvider.notifier).updateLanguage(selectedCode);
    final label = languageOptionFor(selectedCode).label;
    _showFeedback('Idioma actualizado a $label');
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(preferencesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificaciones por email'),
            value: preferences.emailNotifications,
            onChanged: (value) {
              ref
                  .read(preferencesProvider.notifier)
                  .updateEmailNotifications(value);
              _showFeedback(
                value
                    ? 'Activaste las notificaciones por email.'
                    : 'Desactivaste las notificaciones por email.',
              );
            },
          ),
          SwitchListTile(
            title: const Text('Notificaciones push'),
            subtitle: const Text('Avisos inmediatos en tu dispositivo'),
            value: preferences.pushNotifications,
            onChanged: (value) {
              ref
                  .read(preferencesProvider.notifier)
                  .updatePushNotifications(value);
              _showFeedback(
                value
                    ? 'Activaste las notificaciones push.'
                    : 'Desactivaste las notificaciones push.',
              );
            },
          ),
          SwitchListTile(
            title: const Text('Recordatorios por SMS'),
            value: preferences.smsNotifications,
            onChanged: (value) {
              ref
                  .read(preferencesProvider.notifier)
                  .updateSmsNotifications(value);
              _showFeedback(
                value
                    ? 'Activaste los recordatorios por SMS.'
                    : 'Desactivaste los recordatorios por SMS.',
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Idioma'),
            subtitle: Text(preferences.languageLabel),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _openLanguageSelector(preferences.languageCode),
          ),
        ],
      ),
    );
  }
}
