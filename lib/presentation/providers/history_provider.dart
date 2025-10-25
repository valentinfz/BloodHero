import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/history_item_entity.dart';
import 'centers_provider.dart';

final donationHistoryProvider = FutureProvider.autoDispose<List<HistoryItemEntity>>((ref) {
  // Obtiene la instancia actual del repositorio (sea el falso o el de Firebase)
  final repository = ref.watch(centersRepositoryProvider);
  // Llama al método correspondiente del repositorio y devuelve el Future
  return repository.getDonationHistory();
});
