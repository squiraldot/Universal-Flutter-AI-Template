import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/core/theme/app_theme.dart';
import 'package:universal_app/features/home/presentation/home_page.dart';
import 'package:universal_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('starter home page matches its golden image', (tester) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
      ),
    );

    await expectLater(
      find.byType(HomePage),
      matchesGoldenFile('goldens/home_page.png'),
    );
  });
}
