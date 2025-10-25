import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/alert_provider.dart';

class AlertDetailScreen extends ConsumerWidget {
  static const String name = 'alert_detail_screen';
  final String centerName;

  const AlertDetailScreen({super.key, required this.centerName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Se observa el provider.family pasándole el identificador
    final alertDetailAsync = ref.watch(alertDetailProvider(centerName));

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
                  onPressed: () {
                    // TODO: Implementar la lógica de respuesta con un NotifierProvider
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Quiero ayudar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
