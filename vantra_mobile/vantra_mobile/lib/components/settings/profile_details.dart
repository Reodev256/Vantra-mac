import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ProfileDetailsPage extends StatefulWidget {
  const ProfileDetailsPage({super.key});

  @override
  State<ProfileDetailsPage> createState() => _ProfileDetailsPageState();
}

class _ProfileDetailsPageState extends State<ProfileDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _farmNameController = TextEditingController();
  final _experienceController = TextEditingController();
  
  File? _profileImage;
  String? _currentImagePath;
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('farmers').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userData = doc.data()!;
          _fullNameController.text = _userData?['fullName'] ?? '';
          _usernameController.text = _userData?['username'] ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = _userData?['phone'] ?? '';
          _locationController.text = _userData?['location'] ?? '';
          _farmNameController.text = _userData?['farmName'] ?? '';
          _experienceController.text = _userData?['experience'] ?? '';
          _currentImagePath = _userData?['profileImagePath'];
          _isLoading = false;
        });

        // Load existing profile image if path exists
        if (_currentImagePath != null && _currentImagePath!.isNotEmpty) {
          final file = File(_currentImagePath!);
          if (await file.exists()) {
            setState(() {
              _profileImage = file;
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getProfileImagesDirectory() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String profileImagesDir = path.join(appDir.path, 'profile_images');
    
    // Create directory if it doesn't exist
    final Directory dir = Directory(profileImagesDir);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    
    return profileImagesDir;
  }

  Future<String> _saveImageToLocalStorage(File imageFile, String userId) async {
    final String profileImagesDir = await _getProfileImagesDirectory();
    final String fileName = 'profile_$userId${path.extension(imageFile.path)}';
    final String newImagePath = path.join(profileImagesDir, fileName);
    
    // Copy the image to the new location
    await imageFile.copy(newImagePath);
    
    return newImagePath;
  }

  Future<void> _deleteOldImage(String? imagePath) async {
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        final File oldImage = File(imagePath);
        if (await oldImage.exists()) {
          await oldImage.delete();
        }
      } catch (e) {
        print('Error deleting old image: $e');
      }
    }
  }

  Future<void> _pickImage() async {
  try {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    
    if (image != null && mounted) {
      await _handleNewImage(File(image.path));
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }
}

Future<void> _takePhoto() async {
  try {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    
    if (image != null && mounted) {
      await _handleNewImage(File(image.path));
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: ${e.toString()}')),
      );
    }
  }
}

  Future<void> _handleNewImage(File newImage) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Delete old image if exists
    if (_currentImagePath != null) {
      await _deleteOldImage(_currentImagePath);
    }

    // Save new image to local storage
    final String newImagePath = await _saveImageToLocalStorage(newImage, user.uid);

    setState(() {
      _profileImage = newImage;
      _currentImagePath = newImagePath;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final updateData = {
        'fullName': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'farmName': _farmNameController.text.trim(),
        'experience': _experienceController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add profile image path if available
      if (_currentImagePath != null) {
        updateData['profileImagePath'] = _currentImagePath!;
      }

      // Remove empty fields
      updateData.removeWhere((key, value) => value is String && value.isEmpty);

      await _firestore.collection('farmers').doc(user.uid).set(
        updateData,
        SetOptions(merge: true),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context); // Return to settings page
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showImageSourceDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Profile Picture'),
        content: const Text('Choose image source'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog first
              _pickImage();
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog first
              _takePhoto();
            },
            child: const Text('Camera'),
          ),
          if (_profileImage != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog first
                _removeProfileImage();
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      );
    },
  );
}

  Future<void> _removeProfileImage() async {
  try {
    if (_currentImagePath != null) {
      await _deleteOldImage(_currentImagePath);
    }

    if (mounted) {
      setState(() {
        _profileImage = null;
        _currentImagePath = null;
      });
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing image: ${e.toString()}')),
      );
    }
  }
}

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _farmNameController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Widget _buildProfileImageSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF41754E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: _showImageSourceDialog,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _showImageSourceDialog,
            child: const Text(
              'Change Photo',
              style: TextStyle(color: Color(0xFF41754E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF41754E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Image Section
              _buildProfileImageSection(),
              const SizedBox(height: 24),

              // Personal Information Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF41754E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: 'Full Name',
                        controller: _fullNameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      _buildFormField(
                        label: 'Username',
                        controller: _usernameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.trim().length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      _buildFormField(
                        label: 'Email',
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        enabled: false, // Email cannot be changed
                      ),
                      _buildFormField(
                        label: 'Phone Number',
                        controller: _phoneController,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(value)) {
                              return 'Please enter a valid phone number';
                            }
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Farm Information Section
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Farm Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF41754E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFormField(
                        label: 'Farm Name',
                        controller: _farmNameController,
                        validator: (value) => null, // Optional
                      ),
                      _buildFormField(
                        label: 'Location',
                        controller: _locationController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your farm location';
                          }
                          return null;
                        },
                        maxLines: 2,
                      ),
                      _buildFormField(
                        label: 'Farming Experience',
                        controller: _experienceController,
                        validator: (value) => null, // Optional
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF41754E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Profile',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}