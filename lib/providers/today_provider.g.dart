// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(todayActiveItems)
final todayActiveItemsProvider = TodayActiveItemsProvider._();

final class TodayActiveItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TodayItem>>,
          List<TodayItem>,
          Stream<List<TodayItem>>
        >
    with $FutureModifier<List<TodayItem>>, $StreamProvider<List<TodayItem>> {
  TodayActiveItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayActiveItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayActiveItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<TodayItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TodayItem>> create(Ref ref) {
    return todayActiveItems(ref);
  }
}

String _$todayActiveItemsHash() => r'df210fbdfb7f7f6387e579c600e353fed0f62c36';

@ProviderFor(todayCompletedItems)
final todayCompletedItemsProvider = TodayCompletedItemsProvider._();

final class TodayCompletedItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TodayItem>>,
          List<TodayItem>,
          Stream<List<TodayItem>>
        >
    with $FutureModifier<List<TodayItem>>, $StreamProvider<List<TodayItem>> {
  TodayCompletedItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayCompletedItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayCompletedItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<TodayItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TodayItem>> create(Ref ref) {
    return todayCompletedItems(ref);
  }
}

String _$todayCompletedItemsHash() =>
    r'6d855c719eb512c753e40f3be93be4de080ce051';
