import 'package:flutter/material.dart';

class InfluencerHomePage extends StatelessWidget {
  const InfluencerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Influencer Dashboard")),
      body: const Center(child: Text("Welcome Influencer!")),
    );
  }
}
