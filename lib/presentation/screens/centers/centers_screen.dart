import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bloodhero/config/theme/layout_constants.dart';
import 'package:bloodhero/presentation/screens/filters/filter_screen.dart';
import 'package:bloodhero/presentation/screens/centers/center_detail_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/presentation/widgets/shared/app_button.dart';
import 'package:bloodhero/presentation/widgets/shared/info_card.dart';

import 'centers_loader.dart';

class MapScreen extends StatefulWidget {
  static const String name = 'map_screen';
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  final _distance = const Distance();
  StreamSubscription<Position>? _posSub;

  late final Future<List<MapCenter>> _centersFuture;

  LatLng? _userLatLng;
  bool _gettingLocation = false;
  int? _selectedIndex;

  bool _fittedOnce = false;

  @override
  void initState() {
    super.initState();
    _centersFuture = loadCentersFromAsset('assets/data/centers_ba.json');
    _initLocation();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }

Future<void> _initLocation() async {
  if (!mounted) return;
  setState(() => _gettingLocation = true);

  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }

    // 2) Permisos
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habilitá los permisos de ubicación en Ajustes')),
        );
      }
      return;
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      _userLatLng = LatLng(pos.latitude, pos.longitude);

      _posSub?.cancel();
      _posSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          distanceFilter: 25,
          accuracy: LocationAccuracy.best,
        ),
      ).listen((p) {
        _userLatLng = LatLng(p.latitude, p.longitude);
        if (mounted) setState(() {});
      });

      if (mounted) setState(() {});
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener ubicación: $e')),
      );
    }
  } finally {
    if (mounted) setState(() => _gettingLocation = false);
  }
}


  List<_CenterView> _orderedCenters(List<MapCenter> centers) {
    final list = <_CenterView>[];
    for (final c in centers) {
      double? km;
      if (_userLatLng != null) {
        km = _distance.as(LengthUnit.Kilometer, _userLatLng!, LatLng(c.lat, c.lng));
      }
      list.add(_CenterView(center: c, km: km));
    }
    list.sort((a, b) {
      if (a.km != null && b.km != null) return a.km!.compareTo(b.km!);
      if (a.km != null) return -1;
      if (b.km != null) return 1;
      return a.center.name.compareTo(b.center.name);
    });
    return list;
  }

  Future<void> _fitAll(List<MapCenter> centers) async {
    final points = <LatLng>[
      for (final c in centers) LatLng(c.lat, c.lng),
      if (_userLatLng != null) _userLatLng!,
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

Future<void> _openGoogleSearch(MapCenter c) async {
  final query = Uri.encodeComponent('${c.name} ${c.address}');
  final uri = Uri.parse('https://www.google.com/search?q=$query');

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No se pudo abrir la búsqueda en Google')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<MapCenter>>(
        future: _centersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error cargando centros'));
          }

          final centers = snapshot.data!;
          final ordered = _orderedCenters(centers);
          final initial = _userLatLng ?? LatLng(centers.first.lat, centers.first.lng);

          if (!_fittedOnce) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await _fitAll(centers);
              _fittedOnce = true;
            });
          }

          return Stack(
            children: [
              // ===== MAPA =====
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initial,
                  initialZoom: 13,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.bloodhero.app',
                  ),
                  // Cluster de marcadores
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 45,
                      size: const Size(40, 40),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      markers: List.generate(ordered.length, (i) {
                        final cv = ordered[i];
                        final isSel = _selectedIndex == i;
                        return Marker(
                          point: LatLng(cv.center.lat, cv.center.lng),
                          width: isSel ? 46 : 40,
                          height: isSel ? 46 : 40,
child: GestureDetector(
  onTap: () {
    setState(() => _selectedIndex = i);
    final center = ordered[i].center;

    _mapController.move(LatLng(center.lat, center.lng), 15);

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
                              color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_userLatLng != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _userLatLng!,
                          width: 40,
                          height: 40,
                          child: const Icon(Icons.my_location, color: Colors.blue, size: 28),
                        ),
                      ],
                    ),
                ],
              ),

              // ===== SHEET DESLIZABLE =====
              DraggableScrollableSheet(
                initialChildSize: 0.28,
                minChildSize: 0.20,
                maxChildSize: 0.60,
                builder: (context, scrollController) {
                  return Material(
                    elevation: 12,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    color: Theme.of(context).colorScheme.surface,
                    child: SafeArea(
                      top: false,
                      child: ListView.separated(
                        controller: scrollController,
                        padding: kScreenPadding,
                        itemCount: ordered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: kCardSpacing),
                        itemBuilder: (context, index) {
                          final cv = ordered[index];
                          final isSel = _selectedIndex == index;
                          final dist = cv.km == null ? '—' : '${cv.km!.toStringAsFixed(1)} km';
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              setState(() => _selectedIndex = index);
                              _mapController.move(LatLng(cv.center.lat, cv.center.lng), 15);
                            },
                            child: InfoCard(
                              title: cv.center.name + (isSel ? ' •' : ''),
                              body: [
                                Text(cv.center.address),
                                Text('Distancia: $dist'),
                              ],
                              footer: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  AppButton.secondary(
                                    text: 'Ver detalles',
                                    onPressed: () => context.pushNamed(
                                      CenterDetailScreen.name,                                      
                                      extra: cv.center,
                                    ),
                                    size: AppButtonSize.small,
                                  ),
                                  AppButton.primary(
                                    text: 'Navegar',
                                    onPressed: () => _openGoogleSearch(cv.center),
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
      floatingActionButton: _gettingLocation
          ? const FloatingActionButton(onPressed: null, child: CircularProgressIndicator())
          : FloatingActionButton(
              tooltip: _userLatLng == null ? 'Pedir ubicación' : 'Centrar en mi ubicación',
              onPressed: () async {
                if (_userLatLng == null) {
                  await _initLocation();
                } else {
                  _mapController.move(_userLatLng!, 14);
                }
              },
              child: const Icon(Icons.my_location),
            ),
    );
  }
}

class _CenterView {
  final MapCenter center;
  final double? km;
  _CenterView({required this.center, required this.km});
}