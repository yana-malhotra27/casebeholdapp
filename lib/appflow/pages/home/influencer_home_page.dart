import 'package:casebehold/appflow/pages/details/bid_details_page.dart';
import 'package:casebehold/appflow/pages/profiles/influencer_profilepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class InfluencerHomePage extends StatefulWidget {
  const InfluencerHomePage({super.key});

  @override
  State<InfluencerHomePage> createState() => _InfluencerHomePageState();
}

class _InfluencerHomePageState extends State<InfluencerHomePage> {
  int _selectedIndex = 0;
  String? _username;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    setState(() {
      _username = doc['name'] ?? 'Influencer';
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

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const InfluencerProfilePage()),
    );
  }

  Widget _buildCaseList() {
    final theme = Theme.of(context);
    final caseQuery = FirebaseFirestore.instance.collection('cases').orderBy('timestamp', descending: true);
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
                      "No cases available.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
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

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BidDetailsPage(caseData: caseData),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: theme.colorScheme.surfaceVariant,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.campaign_outlined,
                                color: theme.colorScheme.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    caseData['title'] ?? 'Untitled',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    caseData['summary'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 18, color: Colors.grey),
                          ],
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
        return _buildCaseList();
      case 1:
        return const Center(child: Text("Collaborated cases will be shown here"));
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
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: theme.colorScheme.onPrimary),
            onPressed: _openProfile,
          ),
        ],
      ),
      body: _buildBody(),
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
            NavigationDestination(icon: Icon(Icons.check), label: 'Accepted Bids'),
          ],
        ),
      ),
    );
  }
}
