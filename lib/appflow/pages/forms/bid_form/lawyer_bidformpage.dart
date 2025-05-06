import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LawyerBidFormPage extends StatefulWidget {
  final String caseId;

  const LawyerBidFormPage({
    super.key,
    required this.caseId,
  });

  @override
  State<LawyerBidFormPage> createState() => _LawyerBidFormPageState();
}

class _LawyerBidFormPageState extends State<LawyerBidFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _licenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _feeController = TextEditingController();
  final _strategyController = TextEditingController();
  final _extraDetailsController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _licenseController.dispose();
    _experienceController.dispose();
    _feeController.dispose();
    _strategyController.dispose();
    _extraDetailsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final bidData = {
      'type': 'lawyer',
      'name': _nameController.text.trim(),
      'licenseNumber': _licenseController.text.trim(),
      'experience': _experienceController.text.trim(),
      'expectedFee': _feeController.text.trim(),
      'strategy': _strategyController.text.trim(),
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
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lawyer Bid Form'),
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
              _buildTextField(label: 'License Number', icon: Icons.gavel, controller: _licenseController),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Years of Experience',
                icon: Icons.timelapse,
                controller: _experienceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Expected Fee',
                icon: Icons.money,
                controller: _feeController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                label: 'Proposed Strategy',
                icon: Icons.description,
                controller: _strategyController,
                maxLines: 4,
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
