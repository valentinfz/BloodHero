// class UserImpactEntity {
//   final int livesHelped;
//   final String ranking;
//   final int? achievementsCount; // Parámetro opcional
//
//   const UserImpactEntity({
//     required this.livesHelped,
//     required this.ranking,
//     this.achievementsCount,
//   });
// }

class UserImpactEntity {
  const UserImpactEntity({
    required this.livesHelped,
    required this.ranking,
    this.achievementsCount,
    this.totalDonations = 0,
    this.pointsEarned = 0,
  });

  final int livesHelped;
  final String ranking;
  final int? achievementsCount;
  final int totalDonations;
  final int pointsEarned;

  UserImpactEntity copyWith({
    int? livesHelped,
    String? ranking,
    int? achievementsCount,
    int? totalDonations,
    int? pointsEarned,
  }) {
    return UserImpactEntity(
      livesHelped: livesHelped ?? this.livesHelped,
      ranking: ranking ?? this.ranking,
      achievementsCount: achievementsCount ?? this.achievementsCount,
      totalDonations: totalDonations ?? this.totalDonations,
      pointsEarned: pointsEarned ?? this.pointsEarned,
    );
  }
}
