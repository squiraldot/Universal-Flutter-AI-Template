import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universal_app/app.dart';
import 'package:universal_app/core/config/app_environment.dart';
import 'package:universal_app/core/config/app_environment_provider.dart';
import 'package:universal_app/core/routing/app_router.dart';
import 'package:universal_app/features/sample_tasks/presentation/sample_tasks_page.dart';

void main() {
  testWidgets('home navigation opens the sample feature', (tester) async {
    await tester.pumpWidget(_testApp());

    await tester.tap(find.text('Open sample tasks'));
    await tester.pumpAndSettle();

    expect(find.byType(SampleTasksPage), findsOneWidget);
    expect(find.text('Sample tasks'), findsOneWidget);
  });

  testWidgets('unknown locations show a safe fallback and return home', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(startAtMissingRoute: true));

    expect(find.text('Page not found'), findsOneWidget);
    await tester.tap(find.text('Go home'));
    await tester.pumpAndSettle();

    expect(
      find.text('Your reusable Flutter app foundation is ready.'),
      findsOneWidget,
    );
  });
}

Widget _testApp({bool startAtMissingRoute = false}) {
  return ProviderScope(
    overrides: [
      appEnvironmentProvider.overrideWithValue(
        AppEnvironment.fromValues(name: 'development'),
      ),
      if (startAtMissingRoute)
        appRouterProvider.overrideWith(
          (ref) => createAppRouter(initialLocation: '/missing-page'),
        ),
    ],
    child: const UniversalApp(),
  );
}
