class HistoryItemEntity {
  final String date;
  final String center;
  final String type;
  final bool wasCompleted; // Si la donación se realizó o fue cancelada

  const HistoryItemEntity({
    required this.date,
    required this.center,
    required this.type,
    required this.wasCompleted,
  });
}
