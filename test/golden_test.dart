import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('solid color sample matches its golden image', (tester) async {
    tester.view.physicalSize = const Size(4, 4);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Keep the expected pixels independent from the widget under test.
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 4, 4),
      Paint()..color = const Color(0xFFFF0000),
    );
    final image = await recorder.endRecording().toImage(4, 4);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();

    final goldenFile = File('test/goldens/solid_red.png');
    addTearDown(() async {
      if (await goldenFile.exists()) {
        await goldenFile.delete();
      }
    });
    await goldenFile.parent.create(recursive: true);
    await goldenFile.writeAsBytes(png!.buffer.asUint8List());

    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            key: ValueKey('golden-sample'),
            width: 4,
            height: 4,
            child: ColoredBox(color: Color(0xFFFF0000)),
          ),
        ),
      ),
    );

    await expectLater(
      find.byKey(const ValueKey('golden-sample')),
      matchesGoldenFile('goldens/solid_red.png'),
    );
  });
}
