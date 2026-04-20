// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deadlines_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(activeDeadlines)
final activeDeadlinesProvider = ActiveDeadlinesProvider._();

final class ActiveDeadlinesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DeadlineWithDate>>,
          List<DeadlineWithDate>,
          Stream<List<DeadlineWithDate>>
        >
    with
        $FutureModifier<List<DeadlineWithDate>>,
        $StreamProvider<List<DeadlineWithDate>> {
  ActiveDeadlinesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeDeadlinesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeDeadlinesHash();

  @$internal
  @override
  $StreamProviderElement<List<DeadlineWithDate>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<DeadlineWithDate>> create(Ref ref) {
    return activeDeadlines(ref);
  }
}

String _$activeDeadlinesHash() => r'50e5e7d8602dc813fe3de40262f74c32beffdb48';
