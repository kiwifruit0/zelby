// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'layout_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LayoutNotifier)
final layoutProvider = LayoutNotifierProvider._();

final class LayoutNotifierProvider
    extends $NotifierProvider<LayoutNotifier, LayoutStateData> {
  LayoutNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'layoutProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$layoutNotifierHash();

  @$internal
  @override
  LayoutNotifier create() => LayoutNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LayoutStateData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LayoutStateData>(value),
    );
  }
}

String _$layoutNotifierHash() => r'253b2d3b7892b3f561f18e2c13d8b84ebc9f5aa3';

abstract class _$LayoutNotifier extends $Notifier<LayoutStateData> {
  LayoutStateData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LayoutStateData, LayoutStateData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LayoutStateData, LayoutStateData>,
              LayoutStateData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
