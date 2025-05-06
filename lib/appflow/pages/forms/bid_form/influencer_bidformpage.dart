import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InfluencerBidFormPage extends StatefulWidget {
  final String caseId;

  const InfluencerBidFormPage({
    super.key,
    required this.caseId,
  });

  @override
  State<InfluencerBidFormPage> createState() => _InfluencerBidFormPageState();
}

class _InfluencerBidFormPageState extends State<InfluencerBidFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _platformNameController = TextEditingController();
  final _linkController = TextEditingController();
  final _amountController = TextEditingController();
  final _messageController = TextEditingController();
  final _extraDetailsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _platformNameController.dispose();
    _linkController.dispose();
    _amountController.dispose();
    _messageController.dispose();
    _extraDetailsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final bidData = {
      'type': 'influencer',
      'name': _nameController.text.trim(),
      'platformName': _platformNameController.text.trim(),
      'link': _linkController.text.trim(),
      'amount': _amountController.text.trim(),
      'message': _messageController.text.trim(),
      'extraDetails': _extraDetailsController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'caseId': widget.caseId,
    };

    try {
      await FirebaseFirestore.instance.collection('bids').add(bidData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bid submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    bool required = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return '$label is required';
        }
        if (label == 'Bidding Amount or Share' && double.tryParse(value!) == null) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Your Bid'),
        leading: const BackButton(),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(label: 'Your Name', icon: Icons.person, controller: _nameController),
              const SizedBox(height: 16),
              _buildTextField(label: 'Platform Name', icon: Icons.web, controller: _platformNameController),
              const SizedBox(height: 16),
              _buildTextField(label: 'Platform/Profile Link', icon: Icons.link, controller: _linkController),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Bidding Amount or Share',
                icon: Icons.attach_money,
                controller: _amountController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Message to Case Poster',
                icon: Icons.message,
                controller: _messageController,
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Other Details (Optional)',
                icon: Icons.note_alt,
                controller: _extraDetailsController,
                maxLines: 3,
                required: false,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _submitForm,
                  child: const Text("Submit Bid"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
