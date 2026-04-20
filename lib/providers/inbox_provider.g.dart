// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inboxTasks)
final inboxTasksProvider = InboxTasksProvider._();

final class InboxTasksProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          List<Item>,
          Stream<List<Item>>
        >
    with $FutureModifier<List<Item>>, $StreamProvider<List<Item>> {
  InboxTasksProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inboxTasksProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inboxTasksHash();

  @$internal
  @override
  $StreamProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Item>> create(Ref ref) {
    return inboxTasks(ref);
  }
}

String _$inboxTasksHash() => r'a08cf8694e2d6c9996d8321123522386587d399e';
