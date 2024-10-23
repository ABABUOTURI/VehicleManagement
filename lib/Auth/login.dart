import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:vehicle/Pages/CompanyManager/CompanyDashboard.dart';
import 'package:vehicle/Auth/Signup.dart';
import 'package:vehicle/Pages/Driver/DriverDashboard.dart';
import 'package:vehicle/Pages/ParkingAttendant/Dashboard.dart';
import 'package:vehicle/models/user.dart'; // Import the User model

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login method using Hive for local storage and role matching
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Open the box for users
        var userBox = await Hive.openBox<User>('users'); // Open Hive box of User objects
        User? user = userBox.get(_emailController.text.trim()); // Retrieve the user based on email key

        if (user != null) {
          // Compare stored password with the entered password
          if (user.password == _passwordController.text.trim()) {
            // Get the user role from Hive and navigate based on role
            String role = user.role;

            _showSuccessDialog(role); // Show success alert before navigating
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid password')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not found')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Show a success dialog before navigating to the dashboard
  void _showSuccessDialog(String role) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Successful'),
          content: const Text('You have successfully logged in.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _navigateToDashboard(role); // Navigate to dashboard
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Navigate to dashboard based on the role
  void _navigateToDashboard(String role) {
    if (role == 'Driver') {
       Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DriverDashboard ()),
      );
    } else if (role == 'Company Manager') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CompanyManagerDashboard(email: '',)),
      );
    } else if (role == 'Parking Attendant') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ParkingAttendantDashboard(email: '',)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role not found!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile icon
            const SizedBox(height: 76),
            const Icon(
              Icons.person,
              size: 80.0,
              color: Color(0xFFDEAF4B),
            ),
            const SizedBox(height: 16),

            // Welcoming message
            const Text(
              'Welcome Back !!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 32),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF63D1F6), // Background color of the button
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 40.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _login,
                          child: const Text(
                            'Login',
                            style: TextStyle(
                                color: Colors.black, // Text color
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),

                  const SizedBox(height: 16),

                  // Link to Signup Page
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignupPage()),
                      );
                    },
                    child: const Center(
                      child: Text(
                        "Don't have an account? Sign up",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
