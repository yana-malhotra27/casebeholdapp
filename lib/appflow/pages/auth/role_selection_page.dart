import 'package:flutter/material.dart';
import 'register_user_page.dart';
import 'register_lawyer_page.dart';
import 'register_influencer_page.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme

    return Scaffold(
      appBar: AppBar(
        title: Text("Choose Role",
            style: TextStyle(
              fontSize: 24,
              color: theme.colorScheme.onPrimary,
            )),
        backgroundColor:
            theme.colorScheme.primary, // Use primary color from theme
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Register as:",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            // User Button
            _buildRoleButton(
              context,
              "User ",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterUserPage()),
                );
              },
              theme,
            ),
            const SizedBox(height: 16),
            // Lawyer Button
            _buildRoleButton(
              context,
              "Lawyer",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterLawyerPage()),
                );
              },
              theme,
            ),
            const SizedBox(height: 16),
            // Influencer Button
            _buildRoleButton(
              context,
              "Influencer",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RegisterInfluencerPage()),
                );
              },
              theme,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build role buttons
  Widget _buildRoleButton(BuildContext context, String role,
      VoidCallback onPressed, ThemeData theme) {
    return SizedBox(
      width: double.infinity, // Make button full width
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor:
              theme.colorScheme.primary, // Use primary color from theme
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          role,
          style: TextStyle(
            color: theme.colorScheme.onPrimary, // Set text color to onPrimary
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
