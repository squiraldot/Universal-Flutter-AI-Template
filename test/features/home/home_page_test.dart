import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/app.dart';
import 'package:universal_app/features/home/presentation/home_page.dart';

void main() {
  testWidgets('starter home displays its welcome content', (tester) async {
    await tester.pumpWidget(const UniversalApp());

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Universal App'), findsOneWidget);
    expect(
      find.text('Your reusable Flutter app foundation is ready.'),
      findsOneWidget,
    );
    expect(
      find.textContaining('reusable architecture'),
      findsOneWidget,
    );
  });
}
