import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/home_providers.dart';
import '../../widgets/custom_bottom_nav_bar.dart';
import '../appointments/citas_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String name = 'home_screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              _ImpactSection(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Se observa el provider del perfil de usuario
    final userProfileAsync = ref.watch(userProfileProvider);

    // .when para manejar los diferentes estados
    return userProfileAsync.when(
      // Mientras carga, no mostramos nada.
      loading: () => const SizedBox.shrink(),
      // Si hay un error, mostramos un saludo generico
      error: (err, stack) => const Text('Hola'),
      // Cuando tenemos los datos, extraemos el nombre y lo mostramos
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
      error: (err, stack) => Text('Error: $err'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alertas cercanas',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: alertsAsync.when(
            loading: () => const _LoadingCard(width: 160),
            error: (err, stack) => Text('Error: $err'),
            data: (alerts) => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _AlertCard(alert: alert);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final dynamic alert;
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
              Text(
                '${alert.bloodType} - urgente',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC62828),
                ),
              ),
              const Spacer(),
              Text(
                '${alert.distance} · ${alert.expiration}',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImpactSection extends ConsumerWidget {
  const _ImpactSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final impactAsync = ref.watch(userImpactProvider);

    return impactAsync.when(
      loading: () => const _LoadingCard(height: 120),
      error: (err, stack) => Text('Error: $err'),
      data: (impact) => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tu impacto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Vidas ayudadas: ${impact.livesHelped}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Ranking: ${impact.ranking}',
                style: const TextStyle(fontSize: 16),
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
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }
}
