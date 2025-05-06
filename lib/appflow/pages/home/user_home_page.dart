import 'package:casebehold/appflow/pages/details/case_detailspage.dart';
import 'package:casebehold/appflow/pages/profiles/user_profilepage.dart';
import 'package:casebehold/appflow/pages/workshops/discussion_page.dart';
import 'package:casebehold/appflow/pages/workshops/workshop_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _selectedIndex = 0;
  String? _username;
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    setState(() {
      _username = doc['name'] ?? 'User';
    });
  }

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
    }
  }

  void _openUserProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const UserProfilePage()),
    );
  }

  void _openPostCaseForm() {
    Navigator.pushNamed(context, '/post-case');
  }

  Future<void> _deleteCase(String caseId) async {
    await FirebaseFirestore.instance.collection('cases').doc(caseId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Case deleted.")),
    );
  }

  Widget _buildPostedCaseSection() {
    final theme = Theme.of(context);
    final caseQuery = FirebaseFirestore.instance
        .collection('cases')
        .where('userId', isEqualTo: _uid)
        .orderBy('timestamp', descending: true);

    final filteredStream = _selectedCategory == 'All'
        ? caseQuery.snapshots()
        : caseQuery.where('category', isEqualTo: _selectedCategory).snapshots();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Filter by category',
              labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
              filled: true,
              fillColor: theme.colorScheme.primary.withOpacity(0.2),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.onPrimary),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            dropdownColor: theme.colorScheme.primary,
            iconEnabledColor: theme.colorScheme.onPrimary,
            style: TextStyle(color: theme.colorScheme.onPrimary),
            items: const [
              DropdownMenuItem(value: 'All', child: Text('All')),
              DropdownMenuItem(value: 'Violence', child: Text('Violence')),
              DropdownMenuItem(value: 'Fraud', child: Text('Fraud')),
              DropdownMenuItem(value: 'Harassment', child: Text('Harassment')),
              DropdownMenuItem(value: 'Property', child: Text('Property')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: filteredStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      "Don't hold back,\npost your case to fight strong!",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final caseData = doc.data() as Map<String, dynamic>;
                  final caseId = doc.id;

                  return Dismissible(
                    key: Key(caseId),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        final confirm = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Case"),
                            content: const Text(
                                "Are you sure you want to delete this case?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () => Navigator.pop(context, false),
                              ),
                              TextButton(
                                child: const Text("Delete"),
                                onPressed: () => Navigator.pop(context, true),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          _deleteCase(caseId);
                        }
                        return confirm;
                      }
                      return false; // No edit functionality
                    },
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CaseDetailsPage(caseData: caseData),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        color: theme.colorScheme.surfaceVariant,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Leading icon
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.campaign_outlined,
                                    color: theme.colorScheme.primary, size: 28),
                              ),
                              const SizedBox(width: 16),

                              // Title and summary
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      caseData['title'] ?? 'Untitled',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      caseData['summary'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Trailing arrow
                              const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildPostedCaseSection();
      case 1:
        return const WorkshopPage();
      case 2:
        return const DiscussionPage();
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: Icon(Icons.logout, color: theme.colorScheme.onPrimary),
          onPressed: _logout,
        ),
        title: Text(
          _username ?? 'Loading...',
          style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.chat_bubble_outline,
                color: theme.colorScheme.onPrimary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chatbot feature coming soon!')),
              );
            },
            tooltip: 'Chatbot',
          ),
          IconButton(
            icon:
                Icon(Icons.person_outline, color: theme.colorScheme.onPrimary),
            onPressed: _openUserProfile,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _openPostCaseForm,
              icon: const Icon(Icons.add),
              label: const Text("New Case"),
            )
          : null,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          height: 56,
          backgroundColor: theme.colorScheme.primary,
          indicatorColor: theme.colorScheme.onPrimary.withOpacity(0.1),
          labelTextStyle: MaterialStateProperty.all(
            theme.textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
          iconTheme: MaterialStateProperty.all(
            IconThemeData(color: theme.colorScheme.onPrimary),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onTabTapped,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.school), label: 'Workshop'),
            NavigationDestination(icon: Icon(Icons.forum), label: 'Discussion'),
          ],
        ),
      ),
    );
  }
}
