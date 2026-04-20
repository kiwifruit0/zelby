// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(upcomingEvents)
final upcomingEventsProvider = UpcomingEventsProvider._();

final class UpcomingEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventWithDates>>,
          List<EventWithDates>,
          Stream<List<EventWithDates>>
        >
    with
        $FutureModifier<List<EventWithDates>>,
        $StreamProvider<List<EventWithDates>> {
  UpcomingEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingEventsHash();

  @$internal
  @override
  $StreamProviderElement<List<EventWithDates>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EventWithDates>> create(Ref ref) {
    return upcomingEvents(ref);
  }
}

String _$upcomingEventsHash() => r'cb9b7a34dcbfb3805ca60e8b0f2224b198059be1';

@ProviderFor(eventsForDateRange)
final eventsForDateRangeProvider = EventsForDateRangeFamily._();

final class EventsForDateRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventWithDates>>,
          List<EventWithDates>,
          Stream<List<EventWithDates>>
        >
    with
        $FutureModifier<List<EventWithDates>>,
        $StreamProvider<List<EventWithDates>> {
  EventsForDateRangeProvider._({
    required EventsForDateRangeFamily super.from,
    required (DateTime, DateTime) super.argument,
  }) : super(
         retry: null,
         name: r'eventsForDateRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventsForDateRangeHash();

  @override
  String toString() {
    return r'eventsForDateRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<EventWithDates>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EventWithDates>> create(Ref ref) {
    final argument = this.argument as (DateTime, DateTime);
    return eventsForDateRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsForDateRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventsForDateRangeHash() =>
    r'e14661a2bb59b852eb08ac093eb87b178048b483';

final class EventsForDateRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<EventWithDates>>,
          (DateTime, DateTime)
        > {
  EventsForDateRangeFamily._()
    : super(
        retry: null,
        name: r'eventsForDateRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventsForDateRangeProvider call(DateTime start, DateTime end) =>
      EventsForDateRangeProvider._(argument: (start, end), from: this);

  @override
  String toString() => r'eventsForDateRangeProvider';
}
