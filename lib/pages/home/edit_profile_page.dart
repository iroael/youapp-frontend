import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart'; // Import model Profile

class EditProfilePage extends StatefulWidget {
  final Profile profile;

  const EditProfilePage({Key? key, required this.profile}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late String _selectedGender;
  late TextEditingController _birthdayController;
  late TextEditingController _horoscopeController;
  late TextEditingController _zodiacController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  List<String> _interests = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with profile data
    _displayNameController = TextEditingController(
      text: widget.profile.username,
    );
    _selectedGender = widget.profile.gender;
    _birthdayController = TextEditingController(text: widget.profile.birthday);
    _horoscopeController = TextEditingController(
      text: widget.profile.horoscope,
    );
    _zodiacController = TextEditingController(text: widget.profile.zodiac);
    _heightController = TextEditingController(
      text: widget.profile.height.toString(),
    );
    _weightController = TextEditingController(
      text: widget.profile.weight.toString(),
    );
    _interests = List.from(widget.profile.interests);
  }

  @override
  void dispose() {
    // Dispose controllers
    _displayNameController.dispose();
    _birthdayController.dispose();
    _horoscopeController.dispose();
    _zodiacController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Function to save profile
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      // Data to send to API
      final data = {
        'name': _displayNameController.text,
        'birthday': _birthdayController.text,
        'height': int.tryParse(_heightController.text) ?? 0,
        'weight': int.tryParse(_weightController.text) ?? 0,
        'interests': _interests,
        // Including additional fields from your form
        'gender': _selectedGender,
        'horoscope': _horoscopeController.text,
        'zodiac': _zodiacController.text,
      };

      final response = await http.put(
        Uri.parse('https://techtest.youapp.ai/api/updateProfile'),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'x-access-token': token,
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        // Success update, return to previous page with status true
        Navigator.of(context).pop(true);
      } else {
        setState(
          () =>
              _error =
                  'Failed to update: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '@${widget.profile.username}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '@${widget.profile.username},',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // About section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'About',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          child: const Text(
                            'Save & Update',
                            style: TextStyle(
                              color: Color(0xFFD4AF37), // Gold color
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Profile image selection
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add, color: Colors.white),
                            SizedBox(height: 4),
                            Text(
                              'Add image',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Form fields with validation
                    _buildFormField(
                      'Display name:',
                      _displayNameController,
                      'Enter name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    _buildDropdownField('Gender:', _selectedGender, [
                      'Male',
                      'Female',
                      'Other',
                    ]),
                    _buildFormField(
                      'Birthday:',
                      _birthdayController,
                      'DD-MM-YYYY',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Birthday is required';
                        }
                        // You could add date format validation here
                        return null;
                      },
                    ),
                    _buildFormField('Horoscope:', _horoscopeController, '--'),
                    _buildFormField('Zodiac:', _zodiacController, '--'),
                    _buildFormField(
                      'Height:',
                      _heightController,
                      'Add height',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Height is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    _buildFormField(
                      'Weight:',
                      _weightController,
                      'Add weight',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Weight is required';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Interest section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Interest',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // Show dialog to edit interests
                            _showInterestsDialog();
                          },
                          icon: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _interests.isNotEmpty
                          ? _interests.join(', ')
                          : 'Add in your interest to find a better match',
                      style: TextStyle(
                        color:
                            _interests.isNotEmpty ? Colors.white : Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Error: $_error',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    String placeholder, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: keyboardType,
                  validator: validator,
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    errorStyle: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value.isNotEmpty ? value : null,
                    hint: Text(
                      'Select Gender',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    dropdownColor: const Color(0xFF2A2A2A),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    style: const TextStyle(color: Colors.white),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                    items:
                        options.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInterestsDialog() {
    final TextEditingController interestController = TextEditingController();
    final List<String> tempInterests = List.from(_interests);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              'Edit Interests',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: interestController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Add new interest',
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    if (interestController.text.isNotEmpty) {
                      tempInterests.add(interestController.text);
                      interestController.clear();
                      (context as Element).markNeedsBuild();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                  ),
                  child: const Text('Add'),
                ),
                const SizedBox(height: 16),
                if (tempInterests.isNotEmpty)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: tempInterests.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            tempInterests[index],
                            style: const TextStyle(color: Colors.white),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              tempInterests.removeAt(index);
                              (context as Element).markNeedsBuild();
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _interests = tempInterests;
                  });
                  Navigator.pop(context);
                },
                child: const Text(
                  'Save',
                  style: TextStyle(color: Color(0xFFD4AF37)),
                ),
              ),
            ],
          ),
    );
  }
}
