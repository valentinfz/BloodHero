import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';
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
      ),
      _AppointmentCardData(
        id: '2',
        center: 'Banco de Sangre Norte',
        date: '05/12/2025',
        time: '09:00',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Citas')),
      body: ListView.separated(
        padding: kScreenPadding,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return InfoCard(
            title: '${appointment.date} · ${appointment.time}',
            body: [Text(appointment.center)],
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const Icon(Icons.chevron_right)],
            ),
            onTap: () => context.pushNamed(
              AppointmentDetailScreen.name,
              extra: appointment.id,
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: kCardSpacing),
        itemCount: appointments.length,
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

  const _AppointmentCardData({
    required this.id,
    required this.center,
    required this.date,
    required this.time,
  });
}
