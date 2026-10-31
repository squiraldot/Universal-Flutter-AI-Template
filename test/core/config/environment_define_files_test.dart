import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const expectedEnvironments = {
    'development': 'development',
    'staging': 'staging',
    'production': 'production',
  };

  for (final entry in expectedEnvironments.entries) {
    test('${entry.key} define file contains only its public environment name', () {
      final file = File('config/${entry.key}.json');
      final values = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      expect(values, {'APP_ENV': entry.value});
      expect(values.values.every((value) => value is String), isTrue);
    });
  }
}
