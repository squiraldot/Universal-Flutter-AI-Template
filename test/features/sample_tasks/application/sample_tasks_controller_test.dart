import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/features/sample_tasks/application/sample_tasks_controller.dart';
import 'package:universal_app/features/sample_tasks/data/sample_tasks_repository.dart';
import 'package:universal_app/features/sample_tasks/domain/sample_task.dart';

void main() {
  test('loads sample tasks from the injected repository', () async {
    final container = ProviderContainer(
      overrides: [
        sampleTasksRepositoryProvider.overrideWithValue(
          _FakeSampleTasksRepository(const [
            SampleTask(id: 'one', title: 'Injected task'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final tasks = await container.read(sampleTasksProvider.future);

    expect(tasks.single.title, 'Injected task');
  });

  test('toggles completion without mutating the original task', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final original = (await container.read(sampleTasksProvider.future)).first;
    container.read(sampleTasksProvider.notifier).toggleCompleted(original.id);

    final updated = container.read(sampleTasksProvider).requireValue.first;
    expect(updated.isCompleted, isTrue);
    expect(original.isCompleted, isFalse);
  });

  test('supports an empty repository result', () async {
    final container = ProviderContainer(
      overrides: [
        sampleTasksRepositoryProvider.overrideWithValue(
          _FakeSampleTasksRepository(const []),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(await container.read(sampleTasksProvider.future), isEmpty);
  });

  test('reload recovers after a repository failure', () async {
    final repository = _FailOnceRepository();
    final container = ProviderContainer(
      overrides: [
        sampleTasksRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(sampleTasksProvider.future),
      throwsA(isA<StateError>()),
    );
    await container.read(sampleTasksProvider.notifier).reload();

    expect(
      container.read(sampleTasksProvider).requireValue.single.id,
      'recovered',
    );
  });
}

class _FakeSampleTasksRepository implements SampleTasksRepository {
  const _FakeSampleTasksRepository(this.tasks);

  final List<SampleTask> tasks;

  @override
  Future<List<SampleTask>> loadTasks() async => tasks;
}

class _FailOnceRepository implements SampleTasksRepository {
  var _hasFailed = false;

  @override
  Future<List<SampleTask>> loadTasks() async {
    if (!_hasFailed) {
      _hasFailed = true;
      throw StateError('Private repository diagnostic');
    }
    return const [SampleTask(id: 'recovered', title: 'Recovered task')];
  }
}
