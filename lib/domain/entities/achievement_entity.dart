class AchievementEntity {
  final String title;
  final String description;
  final String iconName; // Podríamos usar nombres de iconos para mostrarlos

  const AchievementEntity({
    required this.title,
    required this.description,
    this.iconName = 'emoji_events', // Icono por defecto
  });
}
