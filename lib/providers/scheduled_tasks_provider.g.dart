// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_tasks_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(scheduledTasksForDateRange)
final scheduledTasksForDateRangeProvider = ScheduledTasksForDateRangeFamily._();

final class ScheduledTasksForDateRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScheduledTaskWithDate>>,
          List<ScheduledTaskWithDate>,
          Stream<List<ScheduledTaskWithDate>>
        >
    with
        $FutureModifier<List<ScheduledTaskWithDate>>,
        $StreamProvider<List<ScheduledTaskWithDate>> {
  ScheduledTasksForDateRangeProvider._({
    required ScheduledTasksForDateRangeFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'scheduledTasksForDateRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scheduledTasksForDateRangeHash();

  @override
  String toString() {
    return r'scheduledTasksForDateRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<ScheduledTaskWithDate>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ScheduledTaskWithDate>> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return scheduledTasksForDateRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ScheduledTasksForDateRangeProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scheduledTasksForDateRangeHash() =>
    r'bf775115e463f4a76f04a28ff965213040f20c02';

final class ScheduledTasksForDateRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<ScheduledTaskWithDate>>,
          (DateTime, DateTime)
        > {
  ScheduledTasksForDateRangeFamily._()
    : super(
        retry: null,
        name: r'scheduledTasksForDateRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ScheduledTasksForDateRangeProvider call(DateTime start, DateTime end) =>
      ScheduledTasksForDateRangeProvider._(argument: (start, end), from: this);

  @override
  String toString() => r'scheduledTasksForDateRangeProvider';
}

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
