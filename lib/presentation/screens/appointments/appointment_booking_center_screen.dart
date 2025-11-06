import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';
import '../../providers/centers_provider.dart';
import 'appointment_booking_date_screen.dart';

class AppointmentBookingCenterScreen extends ConsumerWidget {
  static const String name = 'appointment_booking_center_screen';
  final String? preselectedCenter;

  const AppointmentBookingCenterScreen({super.key, this.preselectedCenter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centersAsync = ref.watch(centersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Agendar donación · Centro')),
      // .when para manejar los estados de carga, error y datos
      body: centersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (centers) {
          final selected =
              preselectedCenter ??
              (centers.isNotEmpty ? centers.first.name : '');

          return ListView.separated(
            padding: kScreenPadding,
            itemBuilder: (context, index) {
              final center = centers[index];
              final isSelected = center.name == selected;
              return InfoCard(
                title: center.name,
                body: [Text(center.address)],
                trailing: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                onTap: () => context.pushNamed(
                  AppointmentBookingDateScreen.name,
                  extra: center.name,
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(height: kCardSpacing),
            itemCount: centers.length,
          );
        },
      ),
    );
  }
}
