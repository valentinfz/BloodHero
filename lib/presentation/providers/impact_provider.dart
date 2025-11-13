import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_impact_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/repositories/impact_repository.dart';

class ImpactState {
  // ... (código existente de la clase ImpactState)
  final bool isLoading;
  final UserImpactEntity? stats;
  final List<AchievementEntity> achievements;
  final String? error;

  ImpactState({
    this.isLoading = false,
    this.stats,
    this.achievements = const [], // Valor inicial: lista vacía
    this.error,
  });

  ImpactState copyWith({
    bool? isLoading,
    UserImpactEntity? stats,
    List<AchievementEntity>? achievements,
    String? error,
  }) {
    return ImpactState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      achievements: achievements ?? this.achievements,
      error: error, // Se permite que el error sea nulo para limpiarlo
    );
  }
}

// --- NOTIFIER PARA LAS ESTADÍSTICAS DE IMPACTO ---
class ImpactNotifier extends Notifier<ImpactState> {
  late final ImpactRepository _impactRepository;

  static const List<AchievementLevel> _levels = [
    // ... (lista de niveles sin cambios)
    AchievementLevel(
      level: 1,
      name: 'Primer Héroe',
      title: '🩸 Nivel 1 – Donante Inicial',
      minDonations: 1,
      reward: 'Badge + mensaje de bienvenida',
      description:
          'Tu primera donación puede salvar hasta 3 vidas. ¡Bienvenido a la comunidad BloodHero!',
      badgeEmoji: '🩸',
    ),
    AchievementLevel(
      level: 2,
      name: 'Segundo Pulso',
      title: '❤️ Nivel 2 – Donante Comprometido',
      minDonations: 3,
      reward: 'Insignia + contador visible',
      description: 'Tu compromiso comienza a marcar la diferencia.',
      badgeEmoji: '❤️',
    ),
    AchievementLevel(
      level: 3,
      name: 'Corazón Constante',
      title: '💪 Nivel 3 – Donante Frecuente',
      minDonations: 5,
      reward: 'Fondo especial de perfil',
      description:
          'Gracias por donar de manera regular. ¡Sos ejemplo de constancia!',
      badgeEmoji: '💪',
    ),
    AchievementLevel(
      level: 4,
      name: 'Río de Vida',
      title: '🏅 Nivel 4 – Donante Avanzado',
      minDonations: 10,
      reward: 'Descuento o prioridad en eventos solidarios',
      description: 'Tu constancia fluye como la vida misma.',
      badgeEmoji: '🏅',
    ),
    AchievementLevel(
      level: 5,
      name: 'Guardian del Plasma',
      title: '🕊️ Nivel 5 – Donante Solidario',
      minDonations: 15,
      reward: 'Badge dorada + reconocimiento en ranking local',
      description: 'Sos parte esencial de cada historia que ayudás a escribir.',
      badgeEmoji: '🕊️',
    ),
    AchievementLevel(
      level: 6,
      name: 'Embajador BloodHero',
      title: '🌟 Nivel 6 – Donante Elite',
      minDonations: 20,
      reward: 'Certificado digital + mención en redes / leaderboard',
      description: 'Inspirás a otros a salvar vidas. ¡Gracias por tu ejemplo!',
      badgeEmoji: '🌟',
    ),
    AchievementLevel(
      level: 7,
      name: 'Corazón de Platino',
      title: '💎 Nivel 7 – Donante Legendario',
      minDonations: 30,
      reward: 'Reconocimiento legendario en la comunidad BloodHero',
      description:
          'Tu legado salva vidas una y otra vez. ¡Gracias por tu compromiso legendario!',
      badgeEmoji: '💎',
    ),
  ];

  @override
  ImpactState build() {
    // CAMBIO: Se lee el provider del repositorio de impacto
    _impactRepository = ref.read(impactRepositoryProvider);
    Future.microtask(loadImpactStats);
    return ImpactState();
  }

  Future<void> loadImpactStats() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // CAMBIO: Se usan los métodos del _impactRepository
      final results = await Future.wait([
        _impactRepository.getUserImpactStats(),
        _impactRepository.getAchievements(),
      ]);

      final impactStats = results[0] as UserImpactEntity;
      final achievements = results[1] as List<AchievementEntity>;

      final levelInfo = _computeLevel(impactStats.totalDonations);
      final fullStats = UserImpactEntity(
        livesHelped: impactStats.livesHelped,
        ranking: impactStats.ranking,
        totalDonations: impactStats.totalDonations,
        achievementsCount: achievements.length,
        currentLevel: levelInfo.current,
        nextLevel: levelInfo.next,
        donationsToNextLevel: levelInfo.donationsToNextLevel,
      );

      state = state.copyWith(
        isLoading: false,
        stats: fullStats,
        achievements: achievements,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  _LevelResult _computeLevel(int totalDonations) {
    // ... (código existente de _computeLevel)
    AchievementLevel? current;
    AchievementLevel? next;
    for (final level in _levels) {
      if (totalDonations >= level.minDonations) {
        current = level;
      } else {
        next ??= level;
        break;
      }
    }

    final donationsToNext = next == null
        ? 0
        : (next.minDonations - totalDonations).clamp(0, next.minDonations);

    return _LevelResult(
      current: current,
      next: next,
      donationsToNextLevel: donationsToNext,
    );
  }
}

class _LevelResult {
  // ... (código existente de _LevelResult)
  final AchievementLevel? current;
  final AchievementLevel? next;
  final int donationsToNextLevel;

  const _LevelResult({
    required this.current,
    required this.next,
    required this.donationsToNextLevel,
  });
}
// --- FIN DEL NOTIFIER ---

// --- DEFINICIÓN DEL PROVIDER ---
final impactProvider = NotifierProvider<ImpactNotifier, ImpactState>(() {
  return ImpactNotifier();
});
