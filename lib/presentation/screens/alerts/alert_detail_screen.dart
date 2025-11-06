import 'package:bloodhero/domain/entities/alert_detail_entity.dart';
import 'package:bloodhero/presentation/providers/alert_provider.dart';
import 'package:bloodhero/presentation/providers/alert_response_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class AlertDetailScreen extends ConsumerWidget {
  static const String name = 'alert_detail_screen';
  final String centerName;

  const AlertDetailScreen({super.key, required this.centerName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AlertResponseState>(alertResponseProvider, (previous, next) {
      final messenger = ScaffoldMessenger.of(context);
      final notifier = ref.read(alertResponseProvider.notifier);

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        notifier.reset();
      }

      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        messenger.showSnackBar(
          SnackBar(content: Text(next.successMessage!)),
        );
      }
    });

    // Se observa el provider.family pasándole el identificador
    final alertDetailAsync = ref.watch(alertDetailProvider(centerName));
    final responseState = ref.watch(alertResponseProvider);

    return Scaffold(
      appBar: AppBar(title: Text(centerName)),
      body: alertDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error al cargar detalle: $error')),
        data: (alertDetails) {
          // Si tenemos datos, construimos la UI
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tipo de sangre requerido: ${alertDetails.bloodType}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Urgencia: ${alertDetails.urgency}'),
                      Text(
                        'Cantidad necesaria: ${alertDetails.quantityNeeded}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Descripción',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(alertDetails.description),
                const SizedBox(height: 24),
                const Text('Contacto'),
                const SizedBox(height: 8),
                Text('Teléfono: ${alertDetails.contactPhone}'),
                Text('Email: ${alertDetails.contactEmail}'),
                const Spacer(),
                FilledButton(
                  onPressed: responseState.isLoading
                      ? null
                      : () => _handleRespond(
                            context,
                            ref,
                            alertDetails,
                          ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: responseState.isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Quiero ayudar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRespond(
    BuildContext context,
    WidgetRef ref,
    AlertDetailEntity alertDetails,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar ayuda'),
        content: Text(
          'Vamos a informar al centro ${alertDetails.centerName} que querés ayudar. '
          '¿Deseás continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    final notifier = ref.read(alertResponseProvider.notifier);
    await notifier.respondToAlert(
      alertId: alertDetails.centerName,
      contactPhone: alertDetails.contactPhone,
      contactEmail: alertDetails.contactEmail,
    );

    final state = ref.read(alertResponseProvider);
    if (state.successMessage != null && context.mounted) {
      await _showContactOptions(context, alertDetails);
      notifier.reset();
    }
  }

  Future<void> _showContactOptions(
    BuildContext context,
    AlertDetailEntity alertDetails,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contactate con ${alertDetails.centerName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.call),
                  title: Text(alertDetails.contactPhone),
                  subtitle: const Text('Llamar'),
                  onTap: () => _launchUri(
                    context,
                    Uri(scheme: 'tel', path: alertDetails.contactPhone),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(alertDetails.contactEmail),
                  subtitle: const Text('Enviar email'),
                  onTap: () => _launchUri(
                    context,
                    Uri(
                      scheme: 'mailto',
                      path: alertDetails.contactEmail,
                      queryParameters: {
                        'subject': 'Quiero ayudar con la alerta',
                        'body': 'Hola, quiero colaborar con la alerta en ${alertDetails.centerName}.',
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchUri(BuildContext context, Uri uri) async {
    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No pudimos abrir la aplicación correspondiente.'),
          ),
        );
      }
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
