import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/app.dart';

void main() {
  testWidgets('app launches and displays the home page', (tester) async {
    await tester.pumpWidget(const UniversalApp());
    expect(find.text('Universal App'), findsOneWidget);
  });

  testWidgets('home page opens the AI chat starter', (tester) async {
    await tester.pumpWidget(const UniversalApp());

    await tester.tap(find.byKey(const Key('open-ai-chat')));
    await tester.pumpAndSettle();

    expect(find.text('AI Chat'), findsOneWidget);
    expect(find.textContaining('connect a secure backend'), findsOneWidget);
  });
}
