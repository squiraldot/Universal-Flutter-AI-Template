import 'package:flutter/material.dart';

import '../../features/home/presentation/home_page.dart';
import 'app_routes.dart';
import 'unknown_route_page.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final Widget page = switch (settings.name) {
      AppRoutes.home => const HomePage(),
      AppRoutes.notFound => const UnknownRoutePage(),
      _ => UnknownRoutePage(routeName: settings.name),
    };

    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => UnknownRoutePage(routeName: settings.name),
      settings: settings,
    );
  }
}
