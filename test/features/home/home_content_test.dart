import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/features/home/presentation/home_content.dart';

void main() {
  group('HomeContent', () {
    test('starter content is complete and has the expected display lines', () {
      expect(HomeContent.starter.isComplete, isTrue);
      expect(HomeContent.starter.displayLines, [
        'Your reusable Flutter app foundation is ready.',
        'Start building with reusable architecture, shared UI components, '
            'testing, and automated build workflows.',
      ]);
    });

    test('trims surrounding whitespace from display lines', () {
      const content = HomeContent(
        headline: '  Welcome  ',
        description: '  Start here.  ',
      );

      expect(content.displayLines, ['Welcome', 'Start here.']);
    });

    test('omits blank lines and marks the content incomplete', () {
      const content = HomeContent(
        headline: '  ',
        description: 'Start building.',
      );

      expect(content.displayLines, ['Start building.']);
      expect(content.isComplete, isFalse);
    });
  });
}
