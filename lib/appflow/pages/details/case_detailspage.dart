import 'package:casebehold/appflow/pages/bids/bids_statuspage.dart';
import 'package:flutter/material.dart';

class CaseDetailsPage extends StatelessWidget {
  final Map<String, dynamic> caseData;

  const CaseDetailsPage({super.key, required this.caseData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(caseData['title'] ?? 'Case Details'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: theme.colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetail(context, Icons.category, "Category", caseData['category']),
                    const Divider(height: 30),
                    _buildDetail(context, Icons.description_outlined, "Summary", caseData['summary']),
                    const Divider(height: 30),
                    _buildDetail(context, Icons.picture_as_pdf, "PDF Link", caseData['pdfLink']),
                    const Divider(height: 30),
                    _buildDetail(context, Icons.video_collection, "Video Link", caseData['videoLink']),
                    const Divider(height: 30),
                    _buildDetail(context, Icons.person, "Posted By", caseData['postedBy']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final caseId = caseData['id'];
                  final userId = caseData['userId']; // Get the userId here
                  if (caseId != null || userId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BidsStatusPage(
                          // caseType: caseData['category'], // Pass category as caseType
                          // userId: userId, // Pass userId
                        ),
                      ),
                    );
                  } else {
                    // Handle the case where the ID is missing, perhaps show a message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Case ID or User ID is missing!')),
                    );
                  }
                },
                icon: const Icon(Icons.gavel),
                label: const Text('Check Bids'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, IconData icon, String title, String? value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              SelectableText(
                value?.trim().isEmpty == true ? 'Not provided' : value ?? 'Not available',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
