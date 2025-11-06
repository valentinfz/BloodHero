import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/user_impact_entity.dart';

// Provider para las estadísticas de impacto (vidas, donaciones)
final userImpactStatsProvider = FutureProvider.autoDispose<UserImpactEntity>((ref) async {
  final repository = ref.watch(centersRepositoryProvider);
  // Llamamos al método que obtiene las stats (vidas, ranking)
  final impactStats = await repository.getUserImpactStats();
  // Llamamos al método que obtiene los logros para contar cuántos hay
  final achievements = await repository.getAchievements();
  // Devolvemos una NUEVA entidad UserImpact con el conteo de logros añadido
  return impactStats.copyWith(
    achievementsCount: achievements.length, // Añadimos el conteo
  );
});

// Provider para la lista de logros
final achievementsProvider = FutureProvider.autoDispose<List<AchievementEntity>>((ref) {
  final repository = ref.watch(centersRepositoryProvider);
  return repository.getAchievements();
});
