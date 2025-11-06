import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/impact_provider.dart';

class ImpactDetailScreen extends ConsumerWidget {
  static const String name = 'impact_detail_screen';
  final String achievementTitle;

  const ImpactDetailScreen({super.key, required this.achievementTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementDetailAsync = ref.watch(
      achievementDetailProvider(achievementTitle),
    );

    return Scaffold(
      appBar: AppBar(title: Text(achievementTitle)),
      body: achievementDetailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error al cargar detalles del logro:\n$err',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (details) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen del logro',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(details.description),

                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.share),
                    label: const Text('Compartir logro'),
                    onPressed: () {
                      // Share.share(
                      //   '¡Acabo de lograr "${details.title}" en BloodHero! Sumate y salvemos vidas juntos.',
                      //   subject: 'Mi logro en BloodHero',
                      // );
                      SharePlus.instance.share(
                        ShareParams(
                          text:
                              '¡Acabo de lograr "${details.title}" en BloodHero! Sumate y salvemos vidas juntos.',
                          subject: 'Mi logro en BloodHero',
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
