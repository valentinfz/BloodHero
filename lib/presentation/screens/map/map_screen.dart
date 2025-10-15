import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/screens/filters/filter_screen.dart';
import 'package:bloodhero/presentation/screens/centers/center_detail_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/presentation/widgets/primary_button.dart';

class MapScreen extends StatelessWidget {
  static const String name = 'map_screen';
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final centers = const [
      _CenterCardData('Centro de Salud Norte', '2.5 km', 'Av. Siempre Viva 123'),
      _CenterCardData('Hospital Central', '4.2 km', 'Calle Principal 456'),
      _CenterCardData('Banco de Sangre Sur', '5.7 km', 'Boulevard Paz 789'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de centros'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => context.pushNamed(FilterScreen.name),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Text('Vista de mapa (placeholder)'),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final center = centers[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          center.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(center.address),
                        const SizedBox(height: 4),
                        Text('Distancia: ${center.distance}'),
                        const SizedBox(height: 12),
                        PrimaryButton(
                          text: 'Ver detalles',
                          height: 44,
                          onPressed: () => context.pushNamed(
                            CenterDetailScreen.name,
                            extra: center.name,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: centers.length,
            ),
          ),
        ],
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
