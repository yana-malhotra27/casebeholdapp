import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BidsStatusPage extends StatelessWidget {
  const BidsStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bids'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bids')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No bids available.',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          final bids = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bids.length,
            itemBuilder: (context, index) {
              final bid = bids[index].data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                color: theme.colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bid['name'] ?? 'Unnamed',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Amount: ₹${bid['amount'] ?? 'N/A'}',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Message: ${bid['message'] ?? 'No message'}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      // Text(
                      //   'Case ID: ${bid['caseId'] ?? 'Unknown'}',
                      //   style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                      // ),
                      //const SizedBox(height: 6),
                      Text(
                        'Type: ${bid['type'] ?? 'N/A'}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Platform: ${bid['platformName'] ?? 'N/A'}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
