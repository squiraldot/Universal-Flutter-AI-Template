import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/core/routing/app_router.dart';
import 'package:universal_app/core/routing/app_routes.dart';
import 'package:universal_app/features/home/presentation/home_page.dart';

void main() {
  testWidgets('home route resolves to the existing HomePage', (tester) async {
    await tester.pumpWidget(_testApp(initialRoute: AppRoutes.home));

    expect(find.byType(HomePage), findsOneWidget);
    expect(
      find.text('Your reusable Flutter app foundation is ready.'),
      findsOneWidget,
    );
  });

  testWidgets('named not-found route displays a safe fallback', (tester) async {
    await tester.pumpWidget(_testApp(initialRoute: AppRoutes.notFound));

    expect(find.text('Page not found'), findsOneWidget);
    expect(find.text('Go home'), findsOneWidget);
  });

  testWidgets('unknown route displays a safe fallback and returns home', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(initialRoute: '/missing-page'));

    expect(find.text('Page not found'), findsOneWidget);
    await tester.tap(find.text('Go home'));
    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
  });

  testWidgets('onUnknownRoute also returns the safe fallback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        onUnknownRoute: AppRouter.onUnknownRoute,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).pushNamed('/missing'),
            child: const Text('Open missing route'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open missing route'));
    await tester.pumpAndSettle();

    expect(find.text('Page not found'), findsOneWidget);
  });
}

Widget _testApp({required String initialRoute}) {
  return MaterialApp(
    initialRoute: initialRoute,
    onGenerateRoute: AppRouter.onGenerateRoute,
    onUnknownRoute: AppRouter.onUnknownRoute,
  );
}
