import 'package:flutter/material.dart';

import 'app_routes.dart';

class UnknownRoutePage extends StatelessWidget {
  const UnknownRoutePage({super.key, this.routeName});

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Universal App')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (routeName != null) ...[
                const SizedBox(height: 8),
                Text(
                  'The requested page is unavailable.',
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                },
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
