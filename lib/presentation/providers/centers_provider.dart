import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/fake_centers_repository.dart';
import '../../domain/repositories/centers_repository.dart';
import '../../domain/entities/center_entity.dart';
import '../../domain/entities/center_detail_entity.dart';

// Este es el provider "intercambiable". Cuando conectemos Firebase, solo cambiaremos esta clase.
final centersRepositoryProvider = Provider<CentersRepository>((ref) {
  return FakeCentersRepository();
});

// Provider para la lista de todos los centros:
// Llama al método getCenters() del repositorio actual.
final centersProvider = FutureProvider.autoDispose<List<CenterEntity>>((ref) {
  final repository = ref.watch(centersRepositoryProvider);
  return repository.getCenters();
});

// Provider.family para obtener los detalles de UN centro específico:
// Recibe el nombre del centro como parámetro y llama al método getCenterDetails().
final centerDetailProvider = FutureProvider.autoDispose
    .family<CenterDetailEntity, String>((ref, centerName) {
      final repository = ref.watch(centersRepositoryProvider);
      return repository.getCenterDetails(centerName);
    });
