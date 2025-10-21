import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'impact_detail_screen.dart';
import 'package:bloodhero/presentation/widgets/custom_bottom_nav_bar.dart';

class ImpactScreen extends StatelessWidget {
  static const String name = 'impact_screen';
  const ImpactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = const _ImpactStats(livesHelped: 12, donations: 8, streak: 3);
    final achievements = const [
      _Achievement('Donador frecuente', '3 donaciones en los últimos 6 meses'),
      _Achievement('Héroe en emergencia', 'Respondiste a 2 alertas urgentes'),
      _Achievement('Embajador', 'Invitaste a 5 amigos a donar'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Tu impacto')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _ImpactSummary(stats: stats),
          const SizedBox(height: 24),
          const Text(
            'Tus logros',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...achievements.map(
            (achievement) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.emoji_events,
                  color: Color(0xFFC62828),
                ),
                title: Text(achievement.title),
                subtitle: Text(achievement.subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.pushNamed(
                  ImpactDetailScreen.name,
                  extra: achievement.title,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }
}

class _ImpactStats {
  final int livesHelped;
  final int donations;
  final int streak;

  const _ImpactStats({
    required this.livesHelped,
    required this.donations,
    required this.streak,
  });
}

class _Achievement {
  final String title;
  final String subtitle;

  const _Achievement(this.title, this.subtitle);
}

class _ImpactSummary extends StatelessWidget {
  final _ImpactStats stats;

  const _ImpactSummary({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _ImpactValue(label: 'Vidas', value: stats.livesHelped.toString()),
            _ImpactValue(
              label: 'Donaciones',
              value: stats.donations.toString(),
            ),
            _ImpactValue(label: 'Racha', value: '${stats.streak} meses'),
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
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
