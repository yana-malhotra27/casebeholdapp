import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _caseInterestController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create user with Firebase Auth
      final userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      debugPrint("User  created with UID: ${userCredential.user!.uid}");

      // Store extra user info in Firestore with explicit error handling
      try {
        print("Firebase Auth user created");
        print("Writing to Firestore...");

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': 'user',
          'caseInterest': _caseInterestController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        debugPrint("User  document created successfully in Firestore.");
      } catch (firestoreError) {
        debugPrint("Failed to create Firestore user document: $firestoreError");
        setState(() {
          _error = "Failed to save user data. Please try again.";
          _isLoading = false;
        });
        return; // stop further execution so no navigation happens
      }

      if (mounted) {
        // Navigate to user home using named route
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/user-home',
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("FirebaseAuthException: ${e.message}");
      setState(() => _error = e.message);
    } catch (e) {
      debugPrint("General Exception: $e");
      setState(() => _error = "Something went wrong. Try again.");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _caseInterestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register as User")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) =>
                    value!.isEmpty ? "Name cannot be empty" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (value) =>
                    value!.contains('@') ? null : "Enter a valid email",
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (value) => value!.length < 6
                    ? "Password must be at least 6 characters"
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _caseInterestController,
                decoration:
                    const InputDecoration(labelText: "Type of Case / Interest"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter your case interest" : null,
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              const SizedBox(height: 12),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _registerUser,
                      child: const Text("Register"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
