class AchievementEntity {
  final String title;
  final String description;
  final String? iconName; // Podríamos usar nombres de iconos para mostrarlos
  final DateTime? unlockedAt; // Fecha en que se desbloqueó

  const AchievementEntity({
    required this.title,
    required this.description,
    this.iconName = 'emoji_events', // Icono por defecto
    this.unlockedAt,
  });
}
