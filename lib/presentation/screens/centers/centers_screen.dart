import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/screens/filters/filter_screen.dart';
import 'package:bloodhero/presentation/screens/centers/center_detail_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';
import 'package:bloodhero/presentation/providers/centers_provider.dart';

class CenterScreen extends ConsumerWidget {
  static const String name = 'centers_screen';
  const CenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centersAsync = ref.watch(centersProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centros de donación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => context.pushNamed(FilterScreen.name),
          ),
        ],
      ),
      body: centersAsync.when(
        // Estado de carga: mostramos un spinner
        loading: () => const Center(child: CircularProgressIndicator()),
        // Estado de error: mostramos un mensaje de error
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
        // Estado de datos: tenemos la lista y construimos la UI
        data: (centers) {
          return ListView.separated(
            padding: kScreenPadding,
            itemBuilder: (context, index) {
              final center = centers[index];
              return InfoCard(
                title: center.name,
                body: [
                  Text(center.address),
                  Text('Distancia: ${center.distance}'),
                ],
                footer: AppButton.secondary(
                  text: 'Ver detalles',
                  onPressed: () => context.pushNamed(
                    CenterDetailScreen.name,
                    extra: center.name,
                  ),
                  size: AppButtonSize.small,
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: kCardSpacing),
            itemCount: centers.length,
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}
