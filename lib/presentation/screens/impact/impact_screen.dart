import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';
import '../../../domain/entities/user_impact_entity.dart';
import '../../providers/achievement_provider.dart';
import 'impact_detail_screen.dart';

class ImpactScreen extends ConsumerWidget {
  static const String name = 'impact_screen';
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userImpactStatsProvider);
    final achievementsAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tu impacto')),
      body: ListView(
        padding: kScreenPadding,
        children: [
          statsAsync.when(
            loading: () => const _LoadingCard(height: 100),
            error: (err, stack) => Text('Error: $err'),
            data: (stats) => _ImpactSummary(stats: stats),
          ),
          const SizedBox(height: kSectionSpacing),
          const Text(
            'Tus logros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: kItemSpacing),
          achievementsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error al cargar logros: $err'),
            data: (achievements) {
              if (achievements.isEmpty) {
                return const Text('Aún no has desbloqueado logros.');
              }
              return Column(
                children: achievements.map((achievement) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: kCardSpacing),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(kCardBorderRadius),
                      ),
                      child: ListTile(
                        leading: Icon(
                          // TODO: Mapear achievement.iconName a un IconData real si es necesario
                          Icons.emoji_events,
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
              );
            },
          ),
        ],
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
            _ImpactValue(label: 'Donaciones', value: '8'),
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
