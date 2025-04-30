import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final resp = await http.get(
        Uri.parse('https://techtest.youapp.ai/api/getProfile'),
        headers: {'x-access-token': token},
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body)['data'];
        _profile = Profile.fromJson(data);
      } else {
        _error = 'Failed to load: ${resp.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateInterest(List<String> interests) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final resp = await http.put(
        Uri.parse('https://techtest.youapp.ai/api/updateProfile'),
        headers: {'x-access-token': token, 'Content-Type': 'application/json'},
        body: jsonEncode({'interests': interests}),
      );
      if (resp.statusCode == 200) {
        await loadProfile();
      } else {
        _error = 'Failed to update: ${resp.statusCode}';
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
}
