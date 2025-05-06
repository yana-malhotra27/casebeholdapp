import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:casebehold/appflow/pages/home/user_home_page.dart';
import 'package:casebehold/appflow/pages/home/lawyer_home_page.dart';
import 'package:casebehold/appflow/pages/home/influencer_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null; 
    });

    try {
      // Attempt to sign in the user
      final authResult = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Fetch user document from Firestore
      final uid = authResult.user!.uid;
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // Check if the user document exists
      if (!userDoc.exists) {
        setState(() {
          _error = "User data not found.";
        });
        return;
      }

      // Get the user's role
      final role = userDoc['role'];

      // Navigate to the appropriate home page based on the user's role
      Widget home;
      if (role == 'user') {
        home = const UserHomePage();
      } else if (role == 'lawyer') {
        home = const LawyerHomePage();
      } else {
        home = const InfluencerHomePage();
      }

      // Navigate to the home page
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => home),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      setState(() {
        _error = e.message; // Display specific error message
      });
    } catch (e) {
      // Handle any other errors
      setState(() {
        _error = "Something went wrong. Try again.";
      });
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "CaseBeHold",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
                    filled: true,
                    fillColor: theme.colorScheme.surface.withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                // Display error message if there is one
                if (_error != null)
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                const SizedBox(height: 12),
                // Show loading indicator or login button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                // Button to navigate to the registration page
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/role-selection');
                  },
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.white),
                      children: [
                        const TextSpan(text: "Don't have an account? "),
                        TextSpan(
                          text: "Register here",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
