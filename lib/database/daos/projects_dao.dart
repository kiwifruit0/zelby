import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/item_dates.dart';
import '../tables/items.dart';
import '../tables/projects.dart';

part 'projects_dao.g.dart';

class ProjectItemWithDate {
  const ProjectItemWithDate({
    required this.item,
    required this.itemType,
    this.itemDate,
  });

  final Item item;
  final String itemType;
  final ItemDate? itemDate;
}

class ProjectMembership {
  const ProjectMembership({
    required this.itemId,
    required this.projectId,
    required this.projectName,
  });

  final int itemId;
  final int projectId;
  final String projectName;
}

class ProjectWithItems {
  const ProjectWithItems({
    required this.project,
    required this.items,
  });

  final Item project;
  final List<ProjectItemWithDate> items;
}

@DriftAccessor(tables: [Items, ItemDates, ProjectItems])
class ProjectsDao extends DatabaseAccessor<AppDatabase> with _$ProjectsDaoMixin {
  ProjectsDao(super.db);

  Stream<List<Item>> watchAllProjects() {
    return (select(items)
          ..where((tbl) => tbl.itemType.equals('project') & tbl.deletedAt.isNull())
          ..orderBy([(tbl) => OrderingTerm.asc(tbl.createdAt)]))
        .watch();
  }

  Stream<ProjectWithItems> watchProjectItems(int projectId) {
    final projectAlias = alias(items, 'project_item');
    final memberAlias = alias(items, 'project_member_item');

    final query = select(projectAlias).join([
      leftOuterJoin(
        projectItems,
        projectItems.projectId.equalsExp(projectAlias.id),
      ),
      leftOuterJoin(
        memberAlias,
        memberAlias.id.equalsExp(projectItems.itemId) &
            memberAlias.deletedAt.isNull(),
      ),
      leftOuterJoin(itemDates, itemDates.itemId.equalsExp(memberAlias.id)),
    ])
      ..where(projectAlias.id.equals(projectId))
      ..where(projectAlias.itemType.equals('project'))
      ..where(projectAlias.deletedAt.isNull());

    return query.watch().map((rows) {
      if (rows.isEmpty) {
        throw StateError('Project $projectId not found');
      }

      final project = rows.first.readTable(projectAlias);
      final memberItems = <ProjectItemWithDate>[];

      for (final row in rows) {
        final member = row.readTableOrNull(memberAlias);
        final membership = row.readTableOrNull(projectItems);
        if (member == null || membership == null) {
          continue;
        }

        memberItems.add(
          ProjectItemWithDate(
            item: member,
            itemType: membership.itemType,
            itemDate: row.readTableOrNull(itemDates),
          ),
        );
      }

      return ProjectWithItems(
        project: project,
        items: memberItems,
      );
    });
  }

  Future<int> insertProject(
    String title, {
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();

    return transaction(() async {
      final projectId = await into(items).insert(
        ItemsCompanion.insert(
          title: title,
          notes: notes == null ? const Value.absent() : Value(notes),
          itemType: 'project',
          createdAt: now,
          updatedAt: now,
        ),
      );

      if (startDate != null || endDate != null) {
        await into(itemDates).insert(
          ItemDatesCompanion.insert(
            itemId: Value(projectId),
            startDate: startDate == null
                ? const Value.absent()
                : Value(startDate),
            endDate: endDate == null ? const Value.absent() : Value(endDate),
          ),
        );
      }

      return projectId;
    });
  }

  Future<int> addItemToProject(int projectId, int itemId, String itemType) {
    return into(projectItems).insert(
      ProjectItemsCompanion.insert(
        projectId: projectId,
        itemId: itemId,
        itemType: itemType,
      ),
    );
  }

  Future<ProjectMembership?> getProjectForItem(int itemId) async {
    final memberAlias = alias(projectItems, 'membership');
    final projectAlias = alias(items, 'project');

    final query = select(projectAlias).join([
      innerJoin(
        memberAlias,
        memberAlias.projectId.equalsExp(projectAlias.id),
      ),
    ])
      ..where(memberAlias.itemId.equals(itemId))
      ..where(projectAlias.deletedAt.isNull());

    final rows = await query.get();
    if (rows.isEmpty) return null;

    final project = rows.first.readTable(projectAlias);
    final membership = rows.first.readTable(memberAlias);

    return ProjectMembership(
      itemId: itemId,
      projectId: membership.projectId,
      projectName: project.title,
    );
  }

  Future<int> removeItemFromProject(int projectId, int itemId) {
    return (delete(projectItems)
          ..where((tbl) => tbl.projectId.equals(projectId))
          ..where((tbl) => tbl.itemId.equals(itemId)))
        .go();
  }

  Future<int> softDelete(int id) {
    final now = DateTime.now();

    return (update(items)..where((tbl) => tbl.id.equals(id))).write(
      ItemsCompanion(
        deletedAt: Value(now),
      ),
    );
  }

  Future<void> updateProject(
    int id, {
    String? title,
    String? notes,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final now = DateTime.now();
    var itemUpdate = ItemsCompanion(
      updatedAt: Value(now),
    );

    if (title != null) {
      itemUpdate = itemUpdate.copyWith(title: Value(title));
    }

    if (notes != null) {
      itemUpdate = itemUpdate.copyWith(notes: Value(notes));
    }

    return transaction(() async {
      await (update(items)..where((tbl) => tbl.id.equals(id))).write(itemUpdate);

      if (startDate == null && endDate == null) {
        return;
      }

      final existingDates = await (select(itemDates)
            ..where((tbl) => tbl.itemId.equals(id)))
          .getSingleOrNull();

      final datesCompanion = ItemDatesCompanion(
        startDate: startDate == null
            ? const Value.absent()
            : Value(startDate),
        endDate: endDate == null ? const Value.absent() : Value(endDate),
      );

      if (existingDates == null) {
        await into(itemDates).insert(
          ItemDatesCompanion.insert(
            itemId: Value(id),
            startDate: startDate == null
                ? const Value.absent()
                : Value(startDate),
            endDate: endDate == null ? const Value.absent() : Value(endDate),
          ),
        );
      } else {
        await (update(itemDates)..where((tbl) => tbl.itemId.equals(id))).write(
          datesCompanion,
        );
      }
    });
  }
}
