import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'appointment_booking_center_screen.dart';
import 'appointment_detail_screen.dart';

class CitasScreen extends StatelessWidget {
  static const String name = 'citas_screen';
  const CitasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appointments = const [
      _AppointmentCardData(
        id: '1',
        center: 'Hospital Central',
        date: '12/11/2025',
        time: '10:30',
        status: 'Confirmada',
      ),
      _AppointmentCardData(
        id: '2',
        center: 'Banco de Sangre Norte',
        date: '05/12/2025',
        time: '09:00',
        status: 'Pendiente',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Citas')),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                '${appointment.date} · ${appointment.time}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(appointment.center),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    appointment.status,
                    style: TextStyle(
                      color: appointment.status == 'Confirmada'
                          ? Colors.green
                          : const Color(0xFFC62828),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => context.pushNamed(
                AppointmentDetailScreen.name,
                extra: appointment.id,
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: appointments.length,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(AppointmentBookingCenterScreen.name),
        icon: const Icon(Icons.add),
        label: const Text('Agendar cita'),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}

class _AppointmentCardData {
  final String id;
  final String center;
  final String date;
  final String time;
  final String status;

  const _AppointmentCardData({
    required this.id,
    required this.center,
    required this.date,
    required this.time,
    required this.status,
  });
}
