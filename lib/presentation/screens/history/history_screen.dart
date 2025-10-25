import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/history_provider.dart';
import 'package:bloodhero/config/theme/layout_constants.dart';

class HistoryScreen extends ConsumerWidget {
  static const String name = 'history_screen';
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(donationHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de donaciones')),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error al cargar historial: $error')),
        data: (history) {
          if (history.isEmpty) {
            return const Center(
              child: Text('Aún no tienes donaciones registradas.'),
            );
          }
          return ListView.separated(
            padding: kScreenPadding,
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kCardBorderRadius),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.wasCompleted
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      item.wasCompleted
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      color: item.wasCompleted
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  title: Text('${item.date} · ${item.type}'),
                  subtitle: Text(item.center),
                  trailing: Text(
                    item.wasCompleted ? 'Realizada' : 'Cancelada',
                    style: TextStyle(
                      color: item.wasCompleted
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: kCardSpacing),
            itemCount: history.length,
          );
        },
      ),
    );
  }
}
