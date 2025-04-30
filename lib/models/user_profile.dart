class Profile {
  final String username;
  final String gender;
  final String birthday;
  final String horoscope;
  final String zodiac;
  final int height;
  final int weight;
  final List<String> interests;

  Profile({
    required this.username,
    required this.gender,
    required this.birthday,
    required this.horoscope,
    required this.zodiac,
    required this.height,
    required this.weight,
    required this.interests,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    username: json['username'] ?? '',
    gender: json['gender'] ?? '',
    birthday: json['birthday'] ?? '',
    horoscope: json['horoscope'] ?? '',
    zodiac: json['zodiac'] ?? '',
    height: json['height'] ?? 0,
    weight: json['weight'] ?? 0,
    interests: List<String>.from(json['interests'] ?? []),
  );
}
