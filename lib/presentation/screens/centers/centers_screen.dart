import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/screens/filters/filter_screen.dart';
import 'package:bloodhero/presentation/screens/centers/center_detail_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';

class MapScreen extends StatelessWidget {
  static const String name = 'map_screen';
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final centers = const [
      _CenterCardData(
        'Centro de Salud Norte',
        '2.5 km',
        'Av. Siempre Viva 123',
      ),
      _CenterCardData('Hospital Central', '4.2 km', 'Calle Principal 456'),
      _CenterCardData('Banco de Sangre Sur', '5.7 km', 'Boulevard Paz 789'),
    ];

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
      body: ListView.separated(
        padding: kScreenPadding,
        itemBuilder: (context, index) {
          final center = centers[index];
          return InfoCard(
            title: center.name,
            body: [Text(center.address), Text('Distancia: ${center.distance}')],
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
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }
}

class _CenterCardData {
  final String name;
  final String distance;
  final String address;

  const _CenterCardData(this.name, this.distance, this.address);
}
