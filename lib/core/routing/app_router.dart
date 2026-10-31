import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_page.dart';
import '../../features/sample_tasks/presentation/sample_tasks_page.dart';
import 'app_routes.dart';
import 'unknown_route_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});

GoRouter createAppRouter({String initialLocation = AppRoutes.home}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.sampleTasks,
        builder: (context, state) => const SampleTasksPage(),
      ),
    ],
    errorBuilder: (context, state) =>
        UnknownRoutePage(routeName: state.uri.toString()),
  );
}
