import 'package:bloodhero/presentation/screens/appointments/appointment_booking_date_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/centers_provider.dart';
import 'center_reviews_screen.dart';

class CenterDetailScreen extends ConsumerWidget {
  static const String name = 'center_detail_screen';
  final String? centerName;

  const CenterDetailScreen({super.key, this.centerName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (centerName == null) {
      return const Scaffold(
        body: Center(child: Text('Error: No se especificó un centro.')),
      );
    }

    // Observamos el provider, pasándole el nombre del centro que queremos cargar.
    final centerDetailAsync = ref.watch(centerDetailProvider(centerName!));

    return Scaffold(
      // .when para manejar los estados de carga, error y datos
      body: centerDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (center) {
          // Construimos la UI con los datos.
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Text(center.name),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.reviews_outlined),
                    onPressed: () => context.pushNamed(
                      CenterReviewsScreen.name,
                      extra: center.name,
                    ),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[300],
                          // usar imagen aca
                          child: const Center(child: Text('Imagen del centro')),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _InfoRow(
                        icon: Icons.location_on_outlined,
                        text: center.address,
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.schedule_outlined,
                        text: center.schedule,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Servicios disponibles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Usamos los servicios que vienen del provider
                      ...center.services.map((service) => _BulletItem(service)),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => context.pushNamed(
                          AppointmentBookingDateScreen.name,
                          extra: center.name,
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
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFC62828)),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
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
