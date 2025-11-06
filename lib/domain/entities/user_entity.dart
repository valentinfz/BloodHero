class UserEntity {
  final String name;
  final String email;
  final String phone;
  final String bloodType;
  final String city;
  final String ranking;

  UserEntity({
    required this.name,
    required this.email,
    required this.phone,
    required this.bloodType,
    required this.city,
    required this.ranking,
  });

  UserEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? bloodType,
    String? city,
    String? ranking,
  }) {
    return UserEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bloodType: bloodType ?? this.bloodType,
      city: city ?? this.city,
      ranking: ranking ?? this.ranking,
    );
  }
}
