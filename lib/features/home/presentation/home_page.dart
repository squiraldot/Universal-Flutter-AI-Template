import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universal App')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Template ready. Define your app in docs/APP_SPEC.md, '
            'then ask your AI agent to implement one feature at a time.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
