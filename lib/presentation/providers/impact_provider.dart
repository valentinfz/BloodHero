import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_impact_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/achievement_detail_entity.dart';
import 'centers_provider.dart';

// Provider para las estadísticas de impacto (vidas, ranking, conteo logros)
final userImpactStatsProvider = FutureProvider.autoDispose<UserImpactEntity>((
  ref,
) async {
  final repository = ref.watch(centersRepositoryProvider);
  final impactStats = await repository.getUserImpactStats();
  final achievements = await repository.getAchievements();
  return UserImpactEntity(
    livesHelped: impactStats.livesHelped,
    ranking: impactStats.ranking,
    achievementsCount: achievements.length, // Añadimos el conteo
  );
});

// Provider para la lista de todos los logros
final achievementsProvider =
    FutureProvider.autoDispose<List<AchievementEntity>>((ref) {
      final repository = ref.watch(centersRepositoryProvider);
      return repository.getAchievements();
    });

// Provider.family para obtener los detalles de UN logro específico por su título
final achievementDetailProvider = FutureProvider.autoDispose
    .family<AchievementDetailEntity, String>((ref, achievementTitle) {
      final repository = ref.watch(centersRepositoryProvider);
      return repository.getAchievementDetails(achievementTitle);
    });
