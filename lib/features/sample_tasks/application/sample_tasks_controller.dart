import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sample_tasks_repository.dart';
import '../domain/sample_task.dart';

final sampleTasksRepositoryProvider = Provider<SampleTasksRepository>(
  (ref) => InMemorySampleTasksRepository(),
);

final sampleTasksProvider =
    AsyncNotifierProvider<SampleTasksController, List<SampleTask>>(
      SampleTasksController.new,
    );

class SampleTasksController extends AsyncNotifier<List<SampleTask>> {
  @override
  Future<List<SampleTask>> build() {
    return ref.watch(sampleTasksRepositoryProvider).loadTasks();
  }

  void toggleCompleted(String taskId) {
    final tasks = state.valueOrNull;
    if (tasks == null) {
      return;
    }

    state = AsyncData([
      for (final task in tasks)
        if (task.id == taskId)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ]);
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(sampleTasksRepositoryProvider).loadTasks(),
    );
  }
}
