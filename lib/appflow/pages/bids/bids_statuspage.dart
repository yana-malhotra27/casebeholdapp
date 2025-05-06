import 'package:flutter/material.dart';

class BidsStatusPage extends StatelessWidget {
  final String caseId;
  final String userId; // Add userId here

  const BidsStatusPage({super.key, required this.caseId, required this.userId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bids Status'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Center(
        child: Text(
          'Display bids for Case ID: $caseId\nUser ID: $userId',
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}
