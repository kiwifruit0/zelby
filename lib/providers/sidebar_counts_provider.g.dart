// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sidebar_counts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sidebarCounts)
final sidebarCountsProvider = SidebarCountsProvider._();

final class SidebarCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<SidebarCounts>,
          SidebarCounts,
          Stream<SidebarCounts>
        >
    with $FutureModifier<SidebarCounts>, $StreamProvider<SidebarCounts> {
  SidebarCountsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sidebarCountsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sidebarCountsHash();

  @$internal
  @override
  $StreamProviderElement<SidebarCounts> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<SidebarCounts> create(Ref ref) {
    return sidebarCounts(ref);
  }
}

String _$sidebarCountsHash() => r'2da4cb6a9431ea84130de6cc32f46b617ee8bc61';
