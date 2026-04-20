// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'projects_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allProjects)
final allProjectsProvider = AllProjectsProvider._();

final class AllProjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          List<Item>,
          Stream<List<Item>>
        >
    with $FutureModifier<List<Item>>, $StreamProvider<List<Item>> {
  AllProjectsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allProjectsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allProjectsHash();

  @$internal
  @override
  $StreamProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Item>> create(Ref ref) {
    return allProjects(ref);
  }
}

String _$allProjectsHash() => r'abb2cd0570c20f78335051c9bd5843cae3e408ca';

@ProviderFor(projectItems)
final projectItemsProvider = ProjectItemsFamily._();

final class ProjectItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProjectWithItems>,
          ProjectWithItems,
          Stream<ProjectWithItems>
        >
    with $FutureModifier<ProjectWithItems>, $StreamProvider<ProjectWithItems> {
  ProjectItemsProvider._({
    required ProjectItemsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'projectItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$projectItemsHash();

  @override
  String toString() {
    return r'projectItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<ProjectWithItems> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<ProjectWithItems> create(Ref ref) {
    final argument = this.argument as int;
    return projectItems(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$projectItemsHash() => r'0af4b08832ec87ef2f426a89ee35790444cce942';

final class ProjectItemsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<ProjectWithItems>, int> {
  ProjectItemsFamily._()
    : super(
        retry: null,
        name: r'projectItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ProjectItemsProvider call(int projectId) =>
      ProjectItemsProvider._(argument: projectId, from: this);

  @override
  String toString() => r'projectItemsProvider';
}
