import 'package:bloodhero/presentation/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_impact_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/entities/achievement_detail_entity.dart';
// Se importa el repositorio para poder usarlo dentro del Notifier.
import '../../domain/repositories/centers_repository.dart';

// --- COMENTARIO: Estado para el Notifier de Impacto ---
// Se crea una clase para manejar los diferentes estados posibles al cargar
// las estadísticas de impacto: carga inicial, éxito con datos, o error.
class ImpactState {
  final bool isLoading;
  final UserImpactEntity? stats;
  // --- MEJORA: Se añade la lista de logros al estado ---
  // Ahora el estado contendrá no solo las estadísticas, sino también la
  // lista de logros desbloqueados, centralizando toda la información.
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
// --- FIN DEL ESTADO ---

// --- COMENTARIO: Notifier para las Estadísticas de Impacto ---
// Este Notifier gestiona el estado (ImpactState) de las estadísticas del usuario.
// Contiene la lógica para cargar y recargar los datos desde el repositorio.
class ImpactNotifier extends Notifier<ImpactState> {
  late final CentersRepository _centersRepository;
  static const List<AchievementLevel> _levels = [
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
      description:
          'Sos parte esencial de cada historia que ayudás a escribir.',
      badgeEmoji: '🕊️',
    ),
    AchievementLevel(
      level: 6,
      name: 'Embajador BloodHero',
      title: '🌟 Nivel 6 – Donante Elite',
      minDonations: 20,
      reward: 'Certificado digital + mención en redes / leaderboard',
      description:
          'Inspirás a otros a salvar vidas. ¡Gracias por tu ejemplo!',
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
    _centersRepository = ref.read(centersRepositoryProvider);
    // Carga inicial asincrónica
    Future.microtask(loadImpactStats);
    return ImpactState();
  }

  Future<void> loadImpactStats() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Se obtienen tanto las estadísticas como los logros en paralelo.
      final results = await Future.wait([
        _centersRepository.getUserImpactStats(),
        _centersRepository.getAchievements(),
      ]);

      final impactStats = results[0] as UserImpactEntity;
      final achievements = results[1] as List<AchievementEntity>;

      // Se actualiza la entidad de impacto con la cuenta de logros.
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

      // Se guarda todo en el estado.
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

// --- COMENTARIO: Definición del nuevo StateNotifierProvider ---
// Este es el provider que la UI observará. Proporciona la instancia
// del ImpactNotifier y se encarga de su ciclo de vida.
final impactProvider = NotifierProvider<ImpactNotifier, ImpactState>(() {
  return ImpactNotifier();
});
// --- FIN DEL PROVIDER ---

// --- COMENTARIO: achievementsProvider eliminado ---
// El FutureProvider 'achievementsProvider' ha sido eliminado. La lista de
// logros ahora se obtiene a través de 'impactProvider.select((s) => s.achievements)'.
// Esto centraliza la lógica y evita cargas de datos duplicadas.

// Provider.family para obtener los detalles de UN logro específico por su título
final achievementDetailProvider = FutureProvider.autoDispose
    .family<AchievementDetailEntity, String>((ref, achievementTitle) {
      final repository = ref.watch(centersRepositoryProvider);
      return repository.getAchievementDetails(achievementTitle);
    });
