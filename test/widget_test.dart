import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/app.dart';
import 'package:universal_app/core/config/app_environment.dart';
import 'package:universal_app/core/config/app_environment_provider.dart';

void main() {
  testWidgets('app launches and displays the localized home page', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvironmentProvider.overrideWithValue(
            AppEnvironment.fromValues(name: 'development'),
          ),
        ],
        child: const UniversalApp(),
      ),
    );

    expect(find.text('Universal App'), findsOneWidget);
    expect(
      find.text('Your reusable Flutter app foundation is ready.'),
      findsOneWidget,
    );
  });
}
