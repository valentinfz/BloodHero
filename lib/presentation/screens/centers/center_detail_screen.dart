import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:bloodhero/presentation/screens/appointments/appointment_booking_date_screen.dart';
import '../../../domain/entities/center_detail_entity.dart';
import '../../providers/centers_provider.dart';
import '../../../data/loaders/centers_loader.dart';

class CenterDetailScreen extends ConsumerWidget {
  static const String name = 'center_detail_screen';

  final String? centerName;
  final MapCenter? center;

  const CenterDetailScreen({super.key, this.centerName, this.center});

  Widget _centerImage(BuildContext context, CenterDetailEntity centerData) {
    const placeholder = 'assets/images/centers/placeholder.jpg';
    final src = centerData.image.isNotEmpty
        ? centerData.image
        : (center?.image ?? placeholder);

    final isNetwork = src.startsWith('http');
    final imageWidget = isNetwork
        ? Image.network(
            src,
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Image.asset(
              // Fallback a placeholder si la red falla
              placeholder,
              fit: BoxFit.cover,
              height: 180,
              width: double.infinity,
            ),
          )
        : Image.asset(
            src,
            fit: BoxFit.cover,
            height: 180,
            width: double.infinity,
            // Fallback a placeholder si el asset no carga
            errorBuilder: (_, __, ___) => Container(
              height: 180,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(
                  Icons.business_outlined,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
            ),
          );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageWidget,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameToFetch = center?.name ?? centerName ?? 'Hospital Central';

    final centerDetailAsync = ref.watch(centerDetailProvider(nameToFetch));

    return Scaffold(
      body: centerDetailAsync.when(
        loading: () => Scaffold(
          appBar: AppBar(title: Text(nameToFetch)),
          body: const Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          appBar: AppBar(title: Text(nameToFetch)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error al cargar detalles para "$nameToFetch":\n$err',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        data: (centerData) {
          final lat =
              center?.lat; // Obtenemos lat/lng del objeto 'center' si existe
          final lng = center?.lng;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                centerData.name,
              ), // Usamos el nombre de los datos cargados
              actions: [
                IconButton(
                  icon: const Icon(Icons.reviews_outlined),
                  tooltip: 'Ver reseñas en Google',
                  onPressed: () async {
                    final query = Uri.encodeComponent(
                      '${centerData.name} reseñas',
                    );
                    final uri = Uri.parse(
                      'https://www.google.com/search?q=$query',
                    );
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Abriendo reseñas...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    await Future.delayed(const Duration(milliseconds: 400));
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No se pudo abrir Google'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _centerImage(context, centerData),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFFC62828),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(centerData.address)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Muestra Lat/Lng si venían del objeto 'center' original
                  if (lat != null && lng != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.map_outlined,
                          color: Color(0xFFC62828),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ubicación: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}',
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        color: Color(0xFFC62828),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(centerData.schedule)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Servicios disponibles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (centerData.services.isEmpty)
                    const Text('No hay servicios especificados.')
                  else
                    for (final service in centerData.services)
                      _BulletItem(service),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.pushNamed(
                      AppointmentBookingDateScreen.name,
                      extra: centerData.name,
                    ),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Agendar donación'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(fontSize: 20, color: Color(0xFFC62828)),
          ),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
