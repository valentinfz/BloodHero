import 'package:bloodhero/presentation/providers/appointments_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';
import 'appointment_detail_screen.dart';

class CitasScreen extends ConsumerWidget {
  static const String name = 'citas_screen';
  const CitasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Citas')),
      // .when para manejar los diferentes estados: carga, error y datos listos.
      body: appointmentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (appointments) {
          if (appointments.isEmpty) {
            return const Center(child: Text('Aún no tienes citas agendadas.'));
          }
          // Si tenemos datos, construimos la lista como antes, pero usando los datos del provider.
          return ListView.separated(
            padding: kScreenPadding,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return InfoCard(
                title: '${appointment.date} · ${appointment.time}',
                body: [Text(appointment.location)],
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(
                  AppointmentDetailScreen.name,
                  extra: '1', // TODO: Pasar el ID real de la cita
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: kCardSpacing),
            itemCount: appointments.length,
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }
}
