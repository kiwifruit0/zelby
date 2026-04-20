import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/daos/projects_dao.dart' as dao;
import 'database_provider.dart';
import 'inbox_provider.dart';

part 'projects_provider.g.dart';

class ProjectItemWithDate {
  const ProjectItemWithDate({
    required this.item,
    required this.itemType,
    required this.startDate,
    required this.endDate,
  });

  factory ProjectItemWithDate.fromDao(dao.ProjectItemWithDate value) {
    return ProjectItemWithDate(
      item: Item.fromDb(value.item),
      itemType: value.itemType,
      startDate: value.itemDate?.startDate,
      endDate: value.itemDate?.endDate,
    );
  }

  final Item item;
  final String itemType;
  final DateTime? startDate;
  final DateTime? endDate;
}

class ProjectWithItems {
  const ProjectWithItems({
    required this.project,
    required this.items,
  });

  factory ProjectWithItems.fromDao(dao.ProjectWithItems value) {
    return ProjectWithItems(
      project: Item.fromDb(value.project),
      items: value.items.map(ProjectItemWithDate.fromDao).toList(),
    );
  }

  final Item project;
  final List<ProjectItemWithDate> items;
}

@riverpod
Stream<List<Item>> allProjects(Ref ref) {
  final projectsDao = ref.watch(appDatabaseProvider).projectsDao;
  return projectsDao.watchAllProjects().map(
        (rows) => rows.map(Item.fromDb).toList(),
      );
}

@riverpod
Stream<ProjectWithItems> projectItems(Ref ref, int projectId) {
  final projectsDao = ref.watch(appDatabaseProvider).projectsDao;
  return projectsDao.watchProjectItems(projectId).map(ProjectWithItems.fromDao);
}
