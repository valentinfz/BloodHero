import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  static const String name = 'history_screen';
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = const [
      _HistoryItem('12/11/2025', 'Hospital Central', 'Sangre total', true),
      _HistoryItem('05/09/2025', 'Banco de Sangre Norte', 'Plaquetas', true),
      _HistoryItem('18/06/2025', 'Clínica San Martín', 'Sangre total', false),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Historial de donaciones')),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final item = history[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item.wasCompleted
                    ? Colors.green.shade100
                    : Colors.red.shade100,
                child: Icon(
                  item.wasCompleted ? Icons.check : Icons.cancel,
                  color: item.wasCompleted ? Colors.green : Colors.red,
                ),
              ),
              title: Text('${item.date} · ${item.type}'),
              subtitle: Text(item.center),
              trailing: Text(item.wasCompleted ? 'Realizada' : 'Cancelada'),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: history.length,
      ),
    );
  }
}

class _HistoryItem {
  final String date;
  final String center;
  final String type;
  final bool wasCompleted;

  const _HistoryItem(this.date, this.center, this.type, this.wasCompleted);
}
