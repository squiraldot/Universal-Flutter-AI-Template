import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/app.dart';
import 'package:universal_app/core/config/app_environment.dart';
import 'package:universal_app/core/config/app_environment_provider.dart';
import 'package:universal_app/core/routing/app_router.dart';
import 'package:universal_app/core/routing/app_routes.dart';
import 'package:universal_app/features/sample_tasks/presentation/sample_tasks_page.dart';

void main() {
  testWidgets('sample feature is addressable through its route', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(initialLocation: AppRoutes.sampleTasks));
    await tester.pumpAndSettle();

    expect(find.byType(SampleTasksPage), findsOneWidget);
    expect(find.text('Sample tasks'), findsOneWidget);
  });

  testWidgets('unknown locations show a safe fallback and return home', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(initialLocation: '/missing-page'));

    expect(find.text('Page not found'), findsOneWidget);
    await tester.tap(find.text('Go home'));
    await tester.pumpAndSettle();

    expect(
      find.text('Your reusable Flutter app foundation is ready.'),
      findsOneWidget,
    );
  });
}

Widget _testApp({required String initialLocation}) {
  return ProviderScope(
    overrides: [
      appEnvironmentProvider.overrideWithValue(
        AppEnvironment.fromValues(name: 'development'),
      ),
      appRouterProvider.overrideWith(
        (ref) => createAppRouter(initialLocation: initialLocation),
      ),
    ],
    child: const UniversalApp(),
  );
}
