import 'package:bloodhero/presentation/providers/impact_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import '../../../domain/entities/user_impact_entity.dart';
// import eliminado: el provider ya se importa por paquete al inicio del archivo
import 'impact_detail_screen.dart';

class ImpactScreen extends ConsumerWidget {
  static const String name = 'impact_screen';
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- COMENTARIO: Se consume el StateNotifierProvider unificado ---
    final impactState = ref.watch(impactProvider);
    // La lista de logros ahora se obtiene directamente del estado.
    final achievements = impactState.achievements;

    return Scaffold(
      appBar: AppBar(title: const Text('Tu impacto')),
      // Se mantiene el RefreshIndicator para recarga manual.
      body: RefreshIndicator(
        onRefresh: () => ref.read(impactProvider.notifier).loadImpactStats(),
        child: ListView(
          padding: kScreenPadding,
          children: [
            // La lógica para mostrar estadísticas no cambia.
            if (impactState.isLoading && impactState.stats == null)
              const _LoadingCard(height: 100)
            else if (impactState.error != null)
              Center(child: Text('Error: ${impactState.error}'))
            else if (impactState.stats != null) ...[
              _ImpactSummary(stats: impactState.stats!),
              const SizedBox(height: kSectionSpacing),
              _LevelSummary(stats: impactState.stats!),
            ]
            else
              const Center(child: Text('No se encontraron estadísticas.')),

            const SizedBox(height: kSectionSpacing),
            const Text(
              'Tus logros',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kItemSpacing),

            // --- MEJORA: Se consume la lista de logros del estado ---
            // Se elimina el `achievementsAsync.when` y se construye la lista
            // directamente desde `achievements`, que ya está en `impactState`.
            if (impactState.isLoading && achievements.isEmpty)
              const _LoadingCard(height: 200)
            else if (achievements.isEmpty)
              const Center(child: Text('Aún no has desbloqueado logros.'))
            else
              Column(
                children: achievements.map((achievement) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: kCardSpacing),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kCardBorderRadius),
                      ),
                      child: ListTile(
                        leading: _AchievementIcon(achievement.iconName),
                        title: Text(achievement.title),
                        subtitle: Text(achievement.description),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.pushNamed(
                          ImpactDetailScreen.name,
                          extra: achievement.title,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            // --- FIN DE LA MEJORA ---
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}

class _ImpactSummary extends StatelessWidget {
  final UserImpactEntity stats;

  const _ImpactSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSectionSpacing),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ImpactValue(label: 'Vidas', value: stats.livesHelped.toString()),
            _ImpactValue(
              label: 'Donaciones',
              value: stats.totalDonations.toString(),
            ),
            _ImpactValue(
              label: 'Logros',
              value: stats.achievementsCount?.toString() ?? '0',
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelSummary extends StatelessWidget {
  final UserImpactEntity stats;

  const _LevelSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    final current = stats.currentLevel;
    final next = stats.nextLevel;
    if (current == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kCardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kSectionSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  current.badgeEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: kItemSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        current.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        current.description,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: kSectionSpacing),
            Text(
              'Total de donaciones: ${stats.totalDonations}',
              style: theme.textTheme.bodyMedium,
            ),
            if (next != null) ...[
              const SizedBox(height: kSmallSpacing),
              LinearProgressIndicator(
                value: next.minDonations == 0
                    ? 1
                    : (stats.totalDonations / next.minDonations)
                        .clamp(0, 1),
                minHeight: 8,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: kSmallSpacing),
              Text(
                'Te faltan ${stats.donationsToNextLevel} donaciones para ${next.title}.',
                style: theme.textTheme.bodySmall,
              ),
            ] else ...[
              const SizedBox(height: kSmallSpacing),
              Text(
                '¡Alcanzaste el máximo nivel BloodHero!',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: kSmallSpacing),
            Text(
              'Recompensa: ${current.reward}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactValue extends StatelessWidget {
  final String label;
  final String value;

  const _ImpactValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: kSmallSpacing),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}

// Widget auxiliar para mostrar carga (opcional, se prodria usar solo CircularProgressIndicator)
class _LoadingCard extends StatelessWidget {
  final double? height;
  const _LoadingCard({this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _AchievementIcon extends StatelessWidget {
  final String? iconName;

  const _AchievementIcon(this.iconName);

  @override
  Widget build(BuildContext context) {
    final emoji = iconName ?? '🏅';
    if (emoji.runes.length == 1 || emoji.runes.length == 2) {
      return Text(
        emoji,
        style: const TextStyle(fontSize: 26),
      );
    }

    return Icon(
      Icons.emoji_events,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
