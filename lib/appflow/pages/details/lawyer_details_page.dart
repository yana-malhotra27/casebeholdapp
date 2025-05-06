import 'package:flutter/material.dart';
import '../forms/bid_form/lawyer_bidformpage.dart';

class LawyerDetailsPage extends StatelessWidget {
  final Map<String, dynamic> caseData;

  const LawyerDetailsPage({super.key, required this.caseData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(caseData['title'] ?? 'Case Details'),
        leading: const BackButton(),
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
              child: FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LawyerBidFormPage(
                        caseId: caseData['userId'] ?? '',
                      ),
                    ),
                  );
                },
                child: const Text("Bid as Lawyer"),
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
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
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
