import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileService {
  Future<bool> updateUserProfile({
    required String token,
    required String name,
    required String birthday,
    required int height,
    required int weight,
    required List<String> interests,
  }) async {
    final url = Uri.parse('https://techtest.youapp.ai/api/updateProfile');

    final response = await http.put(
      url,
      headers: {
        'accept': '*/*',
        'x-access-token': token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'birthday': birthday,
        'height': height,
        'weight': weight,
        'interests': interests,
      }),
    );

    if (response.statusCode == 200) {
      return true; // ✅ berhasil
    } else {
      print('Failed to update profile: ${response.body}');
      return false; // ❌ gagal
    }
  }
}
