class Profile {
  String username;
  String gender;
  String birthday;
  String horoscope;
  String zodiac;
  int height;
  int weight;
  List<String> interests; // Pastikan ini bukan final

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

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
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

  Map<String, dynamic> toJson() => {
    'username': username,
    'gender': gender,
    'birthday': birthday,
    'horoscope': horoscope,
    'zodiac': zodiac,
    'height': height,
    'weight': weight,
    'interests': interests,
  };
}
