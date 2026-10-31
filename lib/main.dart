import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/logging/app_error_reporting.dart';
import 'core/logging/app_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  configureAppErrorReporting(logger: DeveloperAppLogger());
  runApp(const ProviderScope(child: UniversalApp()));
}
