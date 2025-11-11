import 'dart:async';
import 'package:bloodhero/domain/entities/center_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/screens/filters/filter_screen.dart';
import 'package:bloodhero/presentation/screens/centers/center_detail_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';
import '../../providers/centers_provider.dart';
import '../../providers/location_provider.dart';

class CenterScreen extends ConsumerStatefulWidget {
  static const String name = 'centers_screen';
  const CenterScreen({super.key});

  @override
  ConsumerState<CenterScreen> createState() => _CenterScreenState();
}

class _CenterScreenState extends ConsumerState<CenterScreen> {
  final _mapController = MapController();
  final _distance = const Distance();

  int? _selectedIndex;
  bool _fittedOnce = false;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<CenterEntity> _orderedCenters(
    List<CenterEntity> centers,
    LatLng? userLatLng,
  ) {
    final list = centers.map((c) {
      if (userLatLng == null) {
        return c;
      }
      final km = _distance.as(
        LengthUnit.Kilometer,
        userLatLng,
        LatLng(c.lat, c.lng),
      );
      return c.copyWith(distance: km.toStringAsFixed(1));
    }).toList();

    list.sort((a, b) {
      final kmA = a.distance != null ? double.tryParse(a.distance!) : null;
      final kmB = b.distance != null ? double.tryParse(b.distance!) : null;
      if (kmA != null && kmB != null) return kmA.compareTo(kmB);
      if (kmA != null) return -1;
      if (kmB != null) return 1;
      return a.name.compareTo(b.name);
    });
    return list;
  }

  Future<void> _fitAll(List<CenterEntity> centers, LatLng? userLatLng) async {
    final points = <LatLng>[
      for (final c in centers) LatLng(c.lat, c.lng),
      if (userLatLng != null) userLatLng,
    ];
    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 14);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(36)),
    );
  }

  Future<void> _openGoogleSearch(CenterEntity c) async {
    final query = Uri.encodeComponent('${c.name} ${c.address}');
    final uri = Uri.parse('https://www.google.com/search?q=$query');

    // if (!context.mounted) return;
    if (!mounted) return;
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir la búsqueda en Google')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final centersAsync = ref.watch(centersProvider);
    final userLocationAsync = ref.watch(userLocationProvider);

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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error cargando centros: $error')),
        data: (centers) {
          final userLatLng = userLocationAsync.value;
          final ordered = _orderedCenters(centers, userLatLng);
          final initialLatLng =
              userLatLng ??
              (centers.isNotEmpty
                  ? LatLng(centers.first.lat, centers.first.lng)
                  : LatLng(-34.6, -58.4));

          if (!_fittedOnce && centers.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (mounted) {
                await _fitAll(centers, userLatLng);
                setState(() => _fittedOnce = true);
              }
            });
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialLatLng,
                  initialZoom: 13,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.bloodhero.app',
                  ),
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 45,
                      size: const Size(40, 40),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      markers: List.generate(ordered.length, (i) {
                        final center = ordered[i];
                        final isSel = _selectedIndex == i;
                        return Marker(
                          point: LatLng(center.lat, center.lng),
                          width: isSel ? 46 : 40,
                          height: isSel ? 46 : 40,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _selectedIndex = i);
                              _mapController.move(
                                LatLng(center.lat, center.lng),
                                15,
                              );
                              context.pushNamed(
                                CenterDetailScreen.name,
                                extra: center,
                              );
                            },
                            child: Icon(
                              Icons.location_on,
                              size: isSel ? 44 : 36,
                              color: isSel ? Colors.red.shade800 : Colors.red,
                            ),
                          ),
                        );
                      }),
                      builder: (context, markers) => Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (userLatLng != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: userLatLng,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              DraggableScrollableSheet(
                initialChildSize: 0.28,
                minChildSize: 0.20,
                maxChildSize: 0.60,
                builder: (context, scrollController) {
                  return Material(
                    elevation: 12,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    color: Theme.of(context).colorScheme.surface,
                    child: SafeArea(
                      top: false,
                      child: ListView.separated(
                        controller: scrollController,
                        padding: kScreenPadding,
                        itemCount: ordered.length,
            // separatorBuilder: (_, __) =>
            //     const SizedBox(height: kCardSpacing),
            separatorBuilder: (context, _) =>
              const SizedBox(height: kCardSpacing),
                        itemBuilder: (context, index) {
                          final center = ordered[index];
                          final isSel = _selectedIndex == index;
              final dist = center.distance;
              final distLabel = dist == null
                ? '—'
                : dist.trim().endsWith('km')
                  ? dist
                  : '$dist km';
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() => _selectedIndex = index);
                              _mapController.move(
                                LatLng(center.lat, center.lng),
                                15,
                              );
                            },
                            child: InfoCard(
                              title: center.name + (isSel ? ' •' : ''),
                              body: [
                                Text(center.address),
                                Text('Distancia: $distLabel'),
                              ],
                              footer: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  AppButton.secondary(
                                    text: 'Ver detalles',
                                    onPressed: () => context.pushNamed(
                                      CenterDetailScreen.name,
                                      extra: center,
                                    ),
                                    size: AppButtonSize.small,
                                  ),
                                  AppButton.primary(
                                    text: 'Navegar',
                                    onPressed: () => _openGoogleSearch(center),
                                    size: AppButtonSize.small,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      floatingActionButton: userLocationAsync.when(
        loading: () => const FloatingActionButton(
          onPressed: null,
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => FloatingActionButton(
          tooltip: 'Reintentar ubicación',
          onPressed: () => ref.refresh(userLocationProvider),
          child: const Icon(Icons.location_disabled),
        ),
        data: (userLatLng) => FloatingActionButton(
          tooltip: userLatLng == null
              ? 'Obtener ubicación'
              : 'Centrar en mi ubicación',
          onPressed: () async {
            if (userLatLng == null) {
              final _ = ref.refresh(userLocationProvider);
            } else {
              _mapController.move(userLatLng, 14);
            }
          },
          child: Icon(
            userLatLng == null ? Icons.location_searching : Icons.my_location,
          ),
        ),
      ),
    );
  }
}
