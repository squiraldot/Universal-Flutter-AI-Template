import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universal_app/features/sample_tasks/application/sample_tasks_controller.dart';
import 'package:universal_app/features/sample_tasks/data/sample_tasks_repository.dart';
import 'package:universal_app/features/sample_tasks/domain/sample_task.dart';
import 'package:universal_app/features/sample_tasks/presentation/sample_tasks_page.dart';
import 'package:universal_app/l10n/generated/app_localizations.dart';

void main() {
  testWidgets('shows an empty state when the repository has no tasks', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const _FakeSampleTasksRepository([])));
    await tester.pumpAndSettle();

    expect(find.text('No sample tasks yet.'), findsOneWidget);
  });

  testWidgets('shows a safe error and retries loading', (tester) async {
    final repository = _FailOnceRepository();
    await tester.pumpWidget(_testApp(repository));
    await tester.pumpAndSettle();

    expect(
      find.text("We couldn't load sample tasks. Please try again."),
      findsOneWidget,
    );
    expect(find.text('Private repository diagnostic'), findsNothing);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('Recovered task'), findsOneWidget);
  });

  testWidgets('allows a task to be marked complete', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const _FakeSampleTasksRepository([
          SampleTask(id: 'one', title: 'Injected task'),
        ]),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Injected task'));
    await tester.pump();

    final checkbox = tester.widget<CheckboxListTile>(
      find.byType(CheckboxListTile),
    );
    expect(checkbox.value, isTrue);
  });
}

Widget _testApp(SampleTasksRepository repository) {
  return ProviderScope(
    overrides: [
      sampleTasksRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const SampleTasksPage(),
    ),
  );
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
