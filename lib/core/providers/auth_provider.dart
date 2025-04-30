import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  bool isLoading = false;

  // Simpan token di sini
  String? accessToken;

  Future<void> login(String email, String username, String password) async {
    isLoading = true;
    notifyListeners();

    const url = 'https://techtest.youapp.ai/api/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Ambil token
        accessToken = data['access_token'] as String?;
        // Persist ke SharedPreferences

        print('Token berhasil disimpan: ${accessToken}');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', accessToken!);
      } else {
        throw Exception('Login gagal: ${response.body}');
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('token');
    return accessToken;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    accessToken = null;
    notifyListeners();
  }

  Future<void> register(String email, String username, String password) async {
    isLoading = true;
    notifyListeners();

    const url = 'https://techtest.youapp.ai/api/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json', 'Accept': '*/*'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Optional: bisa langsung simpan token kalau API kasih token
        // Atau langsung arahkan user ke login page
      } else {
        throw Exception('Register gagal: ${response.body}');
      }
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
