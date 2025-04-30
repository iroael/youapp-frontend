import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile_page.dart';
import 'edit_interest_page.dart';
import '../../models/user_profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Profile? _profile;
  bool _isLoading = true;
  String? _error;
  final Color _cardColor = const Color(0x1AFFFFFF);
  final Color _bgColor = const Color(0xFF0D1B2A);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final resp = await http.get(
        Uri.parse('https://techtest.youapp.ai/api/getProfile'),
        headers: {'x-access-token': token},
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body)['data'];
        setState(() => _profile = Profile.fromJson(data));
      } else {
        setState(() => _error = 'Failed to load: ${resp.statusCode}');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onEditProfile() async {
    if (_profile == null) return;
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => EditProfilePage(profile: _profile!)),
    );
    if (updated == true) {
      _loadProfile();
    }
  }

  Future<void> _onEditInterest() async {
    if (_profile == null) return;
    // buka halaman EditInterestPage, tunggu hasil List<String> baru
    final updated = await Navigator.of(context).push<List<String>>(
      MaterialPageRoute(
        builder: (_) => EditInterestPage(initialInterests: _profile!.interests),
      ),
    );
    // kalau user menekan Save (pop dengan List<String>), updated != null
    if (updated != null) {
      // update local state dulu agar UI langsung berubah
      setState(() {
        _profile!.interests = updated;
      });
      // kirim juga ke server (opsional)
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final resp = await http.put(
        Uri.parse('https://techtest.youapp.ai/api/updateProfile'),
        headers: {'x-access-token': token, 'Content-Type': 'application/json'},
        body: jsonEncode({'interests': updated}),
      );
      if (resp.statusCode != 200 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save interests on server')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        centerTitle: true,
        title: Text(
          _profile != null ? '@${_profile!.username}' : '',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
              : (_error != null)
              ? Center(
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.white),
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Cover placeholder
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // About card
                    _buildCard(
                      title: 'About',
                      onEdit: _onEditProfile,
                      children: [
                        _infoRow('Username', _profile!.username),
                        _infoRow('Gender', _profile!.gender),
                        _infoRow('Birthday', _profile!.birthday),
                        _infoRow('Horoscope', _profile!.horoscope),
                        _infoRow('Zodiac', _profile!.zodiac),
                        _infoRow('Height', '${_profile!.height} cm'),
                        _infoRow('Weight', '${_profile!.weight} kg'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Interest card
                    _buildCard(
                      title: 'Interest',
                      onEdit: _onEditInterest,
                      children: [
                        if (_profile!.interests.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                _profile!.interests
                                    .map(
                                      (i) => Chip(
                                        label: Text(
                                          i,
                                          style: const TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        backgroundColor: Colors.white,
                                      ),
                                    )
                                    .toList(),
                          )
                        else
                          const Text(
                            'Add in your interest to find a better match',
                            style: TextStyle(color: Colors.white70),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.white),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(color: Colors.white70),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}
