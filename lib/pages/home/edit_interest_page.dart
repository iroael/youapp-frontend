import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditInterestPage extends StatefulWidget {
  final List<String> initialInterests;
  const EditInterestPage({super.key, required this.initialInterests});

  @override
  State<EditInterestPage> createState() => _EditInterestPageState();
}

class _EditInterestPageState extends State<EditInterestPage> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _interests.addAll(widget.initialInterests);
  }

  void _addInterest(String interest) {
    if (interest.trim().isEmpty) return;
    if (!_interests.contains(interest.trim())) {
      setState(() {
        _interests.add(interest.trim());
      });
    }
    _controller.clear();
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('https://techtest.youapp.ai/api/updateProfile');
    final body = jsonEncode({'interests': _interests});

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json', 'x-access-token': token},
        body: body,
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true); // success
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update interests")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF0D1B2A);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Tell everyone about yourself",
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "What interest you?",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Type your interest...",
                hintStyle: const TextStyle(color: Colors.white30),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onSubmitted: _addInterest,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children:
                  _interests
                      .map(
                        (interest) => Chip(
                          label: Text(interest),
                          onDeleted: () => _removeInterest(interest),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
