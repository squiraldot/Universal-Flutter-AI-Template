import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../application/sample_tasks_controller.dart';
import '../domain/sample_task.dart';

class SampleTasksPage extends ConsumerWidget {
  const SampleTasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tasks = ref.watch(sampleTasksProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.sampleTasksTitle)),
      body: tasks.when(
        loading: () => Center(
          child: CircularProgressIndicator(semanticsLabel: l10n.loadingTasks),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.tasksLoadError, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () =>
                      ref.read(sampleTasksProvider.notifier).reload(),
                  child: Text(l10n.retry),
                ),
              ],
            ),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.noTasks));
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final task in items)
                CheckboxListTile(
                  value: task.isCompleted,
                  title: Text(_localizedTaskTitle(l10n, task)),
                  onChanged: (_) => ref
                      .read(sampleTasksProvider.notifier)
                      .toggleCompleted(task.id),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
            ],
          );
        },
      ),
    );
  }

  String _localizedTaskTitle(AppLocalizations l10n, SampleTask task) {
    return switch (task.id) {
      'architecture' => l10n.taskArchitecture,
      'feature' => l10n.taskFeature,
      _ => task.title,
    };
  }
}
