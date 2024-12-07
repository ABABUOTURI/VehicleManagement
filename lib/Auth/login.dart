import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vehicle/Pages/CompanyManager/CompanyDashboard.dart';
import 'package:vehicle/Pages/Driver/DriverDashboard.dart';
import 'package:vehicle/Pages/ParkingAttendant/Dashboard.dart';
import 'package:vehicle/Auth/Signup.dart';

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

  // Login method using Firebase Authentication
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Sign in with Firebase Authentication
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;

        if (user != null) {
          // Fetch user role from Firestore
          _fetchUserRole(user.uid);
        }
      } on FirebaseAuthException catch (e) {
        // Handle error with Firebase Authentication
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.message}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fetch user role from Firestore and navigate accordingly
  Future<void> _fetchUserRole(String userId) async {
    try {
      // Fetch the user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Get the role from Firestore
        String role = userDoc['role'];

        _showSuccessDialog(role); // Show success alert before navigating
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverDashboard()),
      );
    } else if (role == 'Company Manager') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => CompanyManagerDashboard(email: '')),
      );
    } else if (role == 'Parking Attendant') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => ParkingAttendantDashboard(email: '')),
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
                            backgroundColor: const Color(
                                0xFF63D1F6), // Background color of the button
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
