import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vehicle/models/user.dart'; // Ensure you have the correct User model

class ProfilePage extends StatefulWidget {
  final String email;

  const ProfilePage({super.key, required this.email});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load user data from Hive on initialization
  }

  // Method to load the user profile from Hive
  Future<void> _loadUserProfile() async {
    var userBox = await Hive.openBox<User>('users');
    User? user = userBox.get(widget.email); // Retrieve user by email

    if (user != null) {
      setState(() {
        currentUser = user;
        _nameController.text = user.name; // Populate the text fields
        _roleController.text = user.role;
      });
    }
  }

  // Method to update the user profile
  Future<void> _updateUserProfile() async {
    if (_formKey.currentState!.validate()) {
      var userBox = await Hive.openBox<User>('users');

      // Update user details in Hive
      User updatedUser = User(
        email: currentUser!.email,
        name: _nameController.text,
        role: _roleController.text,
        password: currentUser!.password, // Preserve the current password
      );

      await userBox.put(widget.email, updatedUser); // Update in Hive

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      setState(() {
        currentUser = updatedUser; // Update the state with new user data
      });
    }
  }

  // Method to change the user's password
  Future<void> _changePassword(String newPassword) async {
    var userBox = await Hive.openBox<User>('users');

    // Update the password
    User updatedUser = User(
      email: currentUser!.email,
      name: currentUser!.name,
      role: currentUser!.role,
      password: newPassword,
    );

    await userBox.put(widget.email, updatedUser); // Save new password in Hive

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password changed successfully!')),
    );

    setState(() {
      currentUser = updatedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF63D1F6), // AppBar color
        title: const Text('Profile', style: TextStyle(color: Color(0xFF585D61))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: currentUser == null
            ? const Center(child: CircularProgressIndicator()) // Show loading if user data isn't available yet
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role field (Disabled for editing but visible)
                    TextFormField(
                      controller: _roleController,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                      ),
                      enabled: false, // Disable editing of role
                    ),
                    const SizedBox(height: 16),

                    // Update profile button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF63D1F6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 40.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _updateUserProfile,
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Password section
                    const Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Change password button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF63D1F6),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 40.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _showChangePasswordDialog(context);
                      },
                      child: const Text(
                        'Change Password',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // Show a dialog to enter and change password
  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController newPasswordController =
        TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newPasswordController.text ==
                    confirmPasswordController.text) {
                  _changePassword(newPasswordController.text);
                  Navigator.of(context).pop(); // Close dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
