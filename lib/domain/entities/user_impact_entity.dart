class UserImpactEntity {
  final int livesHelped;
  final String ranking;
  final int totalDonations;
  final int? achievementsCount; // Parámetro opcional
  final AchievementLevel? currentLevel;
  final AchievementLevel? nextLevel;
  final int donationsToNextLevel;

  const UserImpactEntity({
    required this.livesHelped,
    required this.ranking,
    required this.totalDonations,
    this.achievementsCount,
    this.currentLevel,
    this.nextLevel,
    this.donationsToNextLevel = 0,
  });
}

class AchievementLevel {
  final int level;
  final String name;
  final String title;
  final int minDonations;
  final String reward;
  final String description;
  final String badgeEmoji;

  const AchievementLevel({
    required this.level,
    required this.name,
    required this.title,
    required this.minDonations,
    required this.reward,
    required this.description,
    required this.badgeEmoji,
  });
}
