import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:casebehold/appflow/widgets/captcha_dialog.dart';

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

    final captchaPassed = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const CaptchaDialog(),
        ) ??
        false;

    if (!captchaPassed) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

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

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/user-home',
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = "Something went wrong. Try again.");
    } finally {
      setState(() => _isLoading = false);
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

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Register as User")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Create Your Account",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration("Full Name", Icons.person),
                      validator: (value) =>
                          value!.isEmpty ? "Name cannot be empty" : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration("Email", Icons.email),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.contains('@') ? null : "Enter a valid email",
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: _inputDecoration("Password", Icons.lock),
                      obscureText: true,
                      validator: (value) => value!.length < 6
                          ? "Password must be at least 6 characters"
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _caseInterestController,
                      decoration:
                          _inputDecoration("Type of Case / Interest", Icons.business),
                      validator: (value) =>
                          value!.isEmpty ? "Please enter your case interest" : null,
                    ),
                    const SizedBox(height: 20),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 300),
                      crossFadeState: _error != null
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Text(
                        _error ?? '',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _registerUser,
                              icon: const Icon(Icons.person_add),
                              label: const Text("Register"),
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
