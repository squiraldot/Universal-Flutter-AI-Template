import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/features/home/presentation/home_content.dart';

void main() {
  group('HomeContent', () {
    test('starter content is ready to display', () {
      expect(HomeContent.starter.isComplete, isTrue);
      expect(
        HomeContent.starter.headline,
        'Your reusable Flutter app foundation is ready.',
      );
    });

    test('content with a blank headline is incomplete', () {
      const content = HomeContent(
        headline: '  ',
        description: 'Start building with reusable components.',
      );

      expect(content.isComplete, isFalse);
    });

    test('content with a blank description is incomplete', () {
      const content = HomeContent(headline: 'Welcome', description: '  ');

      expect(content.isComplete, isFalse);
    });
  });
}
