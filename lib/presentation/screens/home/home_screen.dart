import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav_bar.dart';

// Modelos de datos hardcodeados (para la UI)
class Alert {
  final String bloodType;
  final String distance;
  final String expiration;
  Alert(this.bloodType, this.distance, this.expiration);
}

class Appointment {
  final String date;
  final String time;
  final String location;
  Appointment(this.date, this.time, this.location);
}

class HomeScreen extends StatelessWidget {
  static const String name = 'home_screen';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // --- Datos de ejemplo ---
    final nextAppointment = Appointment(
      'Lun 12/11',
      '10:30',
      'Hospital Central',
    );
    final nearbyAlerts = [
      Alert('O-', '2 km', 'vence hoy'),
      Alert('A+', '5 km', 'vence en 2 días'),
      Alert('B-', '8 km', 'vence en 3 días'),
    ];
    const userName = 'Usuario';
    // ----------------------

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.grey[100],
        elevation: 0,
        title: const _Header(userName: userName),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NextAppointmentCard(appointment: nextAppointment),
              const SizedBox(height: 24),
              _NearbyAlertsSection(alerts: nearbyAlerts),
              const SizedBox(height: 24),
              const _ImpactSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }
}

// --- Widgets internos de la pantalla Home ---

class _Header extends StatelessWidget {
  final String userName;
  const _Header({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hola, $userName',
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  final Appointment appointment;
  const _NextAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFFC62828)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Próxima donación',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
          ],
        ),
      ),
    );
  }
}

class _NearbyAlertsSection extends StatelessWidget {
  final List<Alert> alerts;
  const _NearbyAlertsSection({required this.alerts});

  @override
  Widget build(BuildContext context) {
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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _AlertCard(alert: alert);
            },
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  final Alert alert;
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

class _ImpactSection extends StatelessWidget {
  const _ImpactSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu impacto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Vidas ayudadas: 6', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('Ranking: Donador leal', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
