import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/app.dart';

void main() {
  testWidgets('app launches and displays the home page', (tester) async {
    await tester.pumpWidget(const UniversalApp());
    expect(find.text('Universal App'), findsOneWidget);
    expect(
      find.text('Your reusable Flutter app foundation is ready.'),
      findsOneWidget,
    );
  });
}
