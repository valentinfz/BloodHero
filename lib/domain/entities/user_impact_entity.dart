class UserImpactEntity {
  final int livesHelped;
  final String ranking;
  final int? achievementsCount; // Parámetro opcional

  const UserImpactEntity({
    required this.livesHelped,
    required this.ranking,
    this.achievementsCount,
  });
}
