import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LawyerProfilePage extends StatefulWidget {
  const LawyerProfilePage({super.key});

  @override
  State<LawyerProfilePage> createState() => _LawyerProfilePageState();
}

class _LawyerProfilePageState extends State<LawyerProfilePage> {
  String? _name;
  String? _email;
  String? _practiceArea;
  String? _createdAt;

  @override
  void initState() {
    super.initState();
    _fetchLawyerProfile();
  }

  Future<void> _fetchLawyerProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final timestamp = data?['createdAt'];
        setState(() {
          _name = data?['name'] ?? 'No name';
          _email = data?['email'] ?? user.email ?? 'No email';
          _practiceArea = data?['practiceArea'] ?? 'Not specified';

          // Format Timestamp if available
          if (timestamp != null && timestamp is Timestamp) {
            _createdAt =
                user.metadata.creationTime?.toLocal().toString().split('.')[0];
          } else {
            _createdAt = 'Unknown';
          }
        });
      } else {
        debugPrint('No user profile found for UID: ${user.uid}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lawyer Profile"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Container(
        padding: const EdgeInsets.all(24),
        color: theme.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(theme),
            const SizedBox(height: 32),
            _buildInfoCard("Full Name", _name, theme),
            const SizedBox(height: 16),
            _buildInfoCard("Email Address", _email, theme),
            const SizedBox(height: 16),
            _buildInfoCard("Practice Area", _practiceArea, theme),
            const SizedBox(height: 16),
            _buildInfoCard("Created At", _createdAt, theme), // NEW
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Icon(Icons.account_balance,
                size: 40, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(height: 12),
          Text(
            _name ?? '',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String? value, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value ?? "-",
                    style: theme.textTheme.bodyMedium,
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
