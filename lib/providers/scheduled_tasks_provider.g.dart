// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_tasks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(scheduledTasksForDate)
final scheduledTasksForDateProvider = ScheduledTasksForDateFamily._();

final class ScheduledTasksForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScheduledTaskWithDate>>,
          List<ScheduledTaskWithDate>,
          Stream<List<ScheduledTaskWithDate>>
        >
    with
        $FutureModifier<List<ScheduledTaskWithDate>>,
        $StreamProvider<List<ScheduledTaskWithDate>> {
  ScheduledTasksForDateProvider._({
    required ScheduledTasksForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'scheduledTasksForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scheduledTasksForDateHash();

  @override
  String toString() {
    return r'scheduledTasksForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ScheduledTaskWithDate>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ScheduledTaskWithDate>> create(Ref ref) {
    final argument = this.argument as DateTime;
    return scheduledTasksForDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ScheduledTasksForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scheduledTasksForDateHash() =>
    r'3545cdcc31aea315313389275a0739fe8ace75f5';

final class ScheduledTasksForDateFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<ScheduledTaskWithDate>>,
          DateTime
        > {
  ScheduledTasksForDateFamily._()
    : super(
        retry: null,
        name: r'scheduledTasksForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ScheduledTasksForDateProvider call(DateTime date) =>
      ScheduledTasksForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'scheduledTasksForDateProvider';
}
