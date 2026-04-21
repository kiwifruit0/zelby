// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(scheduleForDateRange)
final scheduleForDateRangeProvider = ScheduleForDateRangeFamily._();

final class ScheduleForDateRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScheduleDay>>,
          List<ScheduleDay>,
          Stream<List<ScheduleDay>>
        >
    with
        $FutureModifier<List<ScheduleDay>>,
        $StreamProvider<List<ScheduleDay>> {
  ScheduleForDateRangeProvider._({
    required ScheduleForDateRangeFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'scheduleForDateRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$scheduleForDateRangeHash();

  @override
  String toString() {
    return r'scheduleForDateRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<ScheduleDay>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ScheduleDay>> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return scheduleForDateRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is ScheduleForDateRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$scheduleForDateRangeHash() =>
    r'9634d62e558922fd6e152de7e2eb026c98f5ceb9';

final class ScheduleForDateRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<ScheduleDay>>,
          (DateTime, DateTime)
        > {
  ScheduleForDateRangeFamily._()
    : super(
        retry: null,
        name: r'scheduleForDateRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ScheduleForDateRangeProvider call(DateTime start, DateTime end) =>
      ScheduleForDateRangeProvider._(argument: (start, end), from: this);

  @override
  String toString() => r'scheduleForDateRangeProvider';
}
