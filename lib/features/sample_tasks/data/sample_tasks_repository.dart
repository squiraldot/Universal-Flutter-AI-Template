import '../domain/sample_task.dart';

abstract interface class SampleTasksRepository {
  Future<List<SampleTask>> loadTasks();
}

final class InMemorySampleTasksRepository implements SampleTasksRepository {
  @override
  Future<List<SampleTask>> loadTasks() async {
    return const [
      SampleTask(id: 'architecture', title: 'Review the app architecture'),
      SampleTask(id: 'feature', title: 'Add your first feature'),
    ];
  }
}
