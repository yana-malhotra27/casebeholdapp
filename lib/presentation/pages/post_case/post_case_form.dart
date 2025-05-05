import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostCaseFormPage extends StatefulWidget {
  const PostCaseFormPage({super.key});

  @override
  State<PostCaseFormPage> createState() => _PostCaseFormPageState();
}

class _PostCaseFormPageState extends State<PostCaseFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _headlineController = TextEditingController();
  final _summaryController = TextEditingController();
  final _pdfLinkController = TextEditingController();
  final _videoLinkController = TextEditingController();

  bool _postWithName = true;
  bool _postAsUnknown = false;

  void _cancel() {
    Navigator.pop(context);
  }

  Future<void> _postCase() async {
    if (_formKey.currentState?.validate() != true) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final caseData = {
      'userId': user.uid,
      'category': _categoryController.text.trim(),
      'title': _headlineController.text.trim(),
      'summary': _summaryController.text.trim(),
      'pdfLink': _pdfLinkController.text.trim(),
      'videoLink': _videoLinkController.text.trim(),
      'postedBy': _postWithName ? user.displayName ?? "User" : "Unknown",
      'timestamp': FieldValue.serverTimestamp(),
    };

    await FirebaseFirestore.instance.collection('cases').add(caseData);

    if (mounted) {
      Navigator.pop(context); // Return to UserHomePage
    }
  }

  void _togglePostOption(bool withName) {
    setState(() {
      _postWithName = withName;
      _postAsUnknown = !withName;
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _headlineController.dispose();
    _summaryController.dispose();
    _pdfLinkController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Post New Case"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Category", _categoryController),
              const SizedBox(height: 12),
              _buildTextField("Headline", _headlineController),
              const SizedBox(height: 12),
              _buildTextField("Summary", _summaryController, maxLines: 4),
              const SizedBox(height: 12),
              _buildTextField("PDF Link", _pdfLinkController),
              const SizedBox(height: 12),
              _buildTextField("Video Link", _videoLinkController),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _postWithName,
                    onChanged: (val) => _togglePostOption(true),
                  ),
                  const Text("Post with your name"),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _postAsUnknown,
                    onChanged: (val) => _togglePostOption(false),
                  ),
                  const Text("Post as unknown"),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: _cancel,
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: _postCase,
                    child: const Text("Post"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.trim().isEmpty ? "Required" : null,
    );
  }
}
