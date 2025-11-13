import '../entities/achievement_detail_entity.dart';
import '../entities/achievement_entity.dart';
import '../entities/user_impact_entity.dart';

abstract class ImpactRepository {
  /// Obtiene las estadísticas de impacto (vidas, donaciones).
  Future<UserImpactEntity> getUserImpactStats();

  /// Obtiene la lista de logros desbloqueados por el usuario.
  Future<List<AchievementEntity>> getAchievements();

  /// Obtiene el detalle de un logro específico.
  Future<AchievementDetailEntity> getAchievementDetails(String title);
}
