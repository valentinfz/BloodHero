import 'package:bloodhero/domain/entities/alert_entity.dart';
import 'package:bloodhero/presentation/providers/home_provider.dart';
import 'package:bloodhero/presentation/providers/location_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../../widgets/shared/app_button.dart';
import '../appointments/citas_screen.dart';
import '../centers/centers_screen.dart';

class HomeScreen extends ConsumerWidget {
  static const String name = 'home_screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const _Header(),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _NextAppointmentCard(),
              SizedBox(height: 24),
              _NearbyAlertsSection(),
              SizedBox(height: 24),
              _DonationTipSection(),
              SizedBox(height: 96),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: AppButton.primary(
          text: 'Agendar donación',
          onPressed: () {
            context.goNamed(CenterScreen.name);
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    return userProfileAsync.when(
      loading: () => const Text(
        'Hola...',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      error: (err, stack) => const Text(
        'Hola',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
      data: (user) => Text(
        'Hola, ${user.name}',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends ConsumerWidget {
  const _NextAppointmentCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentAsync = ref.watch(nextAppointmentProvider);
    return appointmentAsync.when(
      loading: () => const _LoadingCard(height: 120),
      error: (err, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Error al cargar cita: $err'),
        ),
      ),
      data: (appointment) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, color: Color(0xFFC62828)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Próxima donación',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${appointment.date} - ${appointment.time}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      appointment.location,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.goNamed(CitasScreen.name),
                child: const Text('Ver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyAlertsSection extends ConsumerWidget {
  const _NearbyAlertsSection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(nearbyAlertsProvider);
    final userLocationAsync = ref.watch(userLocationProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertas cercanas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: alertsAsync.when(
            loading: () => const Center(child: _LoadingCard(width: 160)),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (alerts) {
              if (alerts.isEmpty) {
                return const Center(child: Text('No hay alertas cerca.'));
              }

              final userLocation = userLocationAsync.asData?.value;
              final distanceCalculator = Distance();

              final decoratedAlerts = alerts.map((alert) {
                if (userLocation != null &&
                    alert.latitude != null &&
                    alert.longitude != null) {
                  final meters = distanceCalculator(
                    LatLng(userLocation.latitude, userLocation.longitude),
                    LatLng(alert.latitude!, alert.longitude!),
                  );
                  final distanceText = meters >= 1000
                      ? '${(meters / 1000).toStringAsFixed(meters < 10000 ? 1 : 0)} km'
                      : '${meters.round()} m';
                  return alert.copyWith(distance: distanceText);
                }

                if (alert.distance.contains('??') ||
                    alert.distance.toLowerCase().contains('calculando') ||
                    alert.distance.isEmpty) {
                  return alert.copyWith(
                    distance: userLocationAsync.isLoading
                        ? 'Calculando distancia...'
                        : 'Distancia no disponible',
                  );
                }

                return alert;
              }).toList();

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: decoratedAlerts.length,
                itemBuilder: (context, index) {
                  final alert = decoratedAlerts[index];
                  return _AlertCard(alert: alert);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertEntity alert;
  const _AlertCard({required this.alert});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if ((alert.centerName ?? '').isNotEmpty) ...[
                Text(
                  alert.centerName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                '${alert.bloodType} urgente',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${alert.distance} · ${alert.expiration}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonationTipSection extends ConsumerWidget {
  const _DonationTipSection();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipAsync = ref.watch(donationTipProvider);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: tipAsync.when(
        loading: () => const _LoadingCard(height: 80),
        error: (err, stack) => const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No se pudo cargar el consejo.'),
        ),
        data: (tip) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Consejo del día',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double? height;
  final double? width;
  const _LoadingCard({this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
