// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'32848c18dd36b350439a45fa6338bf2df6758978';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SearchOverlayVisible)
final searchOverlayVisibleProvider = SearchOverlayVisibleProvider._();

final class SearchOverlayVisibleProvider
    extends $NotifierProvider<SearchOverlayVisible, bool> {
  SearchOverlayVisibleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchOverlayVisibleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchOverlayVisibleHash();

  @$internal
  @override
  SearchOverlayVisible create() => SearchOverlayVisible();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$searchOverlayVisibleHash() =>
    r'a33debe4b276fd274181708a007a8da09b6fe80c';

abstract class _$SearchOverlayVisible extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(IncludePastEvents)
final includePastEventsProvider = IncludePastEventsProvider._();

final class IncludePastEventsProvider
    extends $NotifierProvider<IncludePastEvents, bool> {
  IncludePastEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'includePastEventsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$includePastEventsHash();

  @$internal
  @override
  IncludePastEvents create() => IncludePastEvents();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$includePastEventsHash() => r'ba1961aa48771d4618265a140cfff5dc040a86f5';

abstract class _$IncludePastEvents extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(recentItems)
final recentItemsProvider = RecentItemsProvider._();

final class RecentItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RecentItem>>,
          List<RecentItem>,
          Stream<List<RecentItem>>
        >
    with $FutureModifier<List<RecentItem>>, $StreamProvider<List<RecentItem>> {
  RecentItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<RecentItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RecentItem>> create(Ref ref) {
    return recentItems(ref);
  }
}

String _$recentItemsHash() => r'bc134bc104dabadc384f9d15c421d2b4e7082592';

@ProviderFor(searchCommands)
final searchCommandsProvider = SearchCommandsProvider._();

final class SearchCommandsProvider
    extends
        $FunctionalProvider<
          List<SearchCommand>,
          List<SearchCommand>,
          List<SearchCommand>
        >
    with $Provider<List<SearchCommand>> {
  SearchCommandsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchCommandsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchCommandsHash();

  @$internal
  @override
  $ProviderElement<List<SearchCommand>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SearchCommand> create(Ref ref) {
    return searchCommands(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SearchCommand> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SearchCommand>>(value),
    );
  }
}

String _$searchCommandsHash() => r'df70fda1d37c70144a17f20bf41b3adecf736a4f';

@ProviderFor(filteredCommands)
final filteredCommandsProvider = FilteredCommandsProvider._();

final class FilteredCommandsProvider
    extends
        $FunctionalProvider<
          List<SearchCommand>,
          List<SearchCommand>,
          List<SearchCommand>
        >
    with $Provider<List<SearchCommand>> {
  FilteredCommandsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredCommandsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredCommandsHash();

  @$internal
  @override
  $ProviderElement<List<SearchCommand>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<SearchCommand> create(Ref ref) {
    return filteredCommands(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SearchCommand> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SearchCommand>>(value),
    );
  }
}

String _$filteredCommandsHash() => r'f9b95882593ec9c1456db41f000446f94b9b4030';

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsProvider._();

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SearchResult>>,
          List<SearchResult>,
          FutureOr<List<SearchResult>>
        >
    with
        $FutureModifier<List<SearchResult>>,
        $FutureProvider<List<SearchResult>> {
  SearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @$internal
  @override
  $FutureProviderElement<List<SearchResult>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SearchResult>> create(Ref ref) {
    return searchResults(ref);
  }
}

String _$searchResultsHash() => r'0232f8d44351eaf42cef7edd8617af16367cddf4';
