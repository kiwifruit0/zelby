import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'database_provider.dart';

part 'sidebar_counts_provider.g.dart';

class SidebarCounts {
  const SidebarCounts({
    this.inboxCount = 0,
    this.todayCount = 0,
    this.eventsCount = 0,
    this.deadlinesCount = 0,
    this.projectsCount = 0,
  });

  final int inboxCount;
  final int todayCount;
  final int eventsCount;
  final int deadlinesCount;
  final int projectsCount;
}

@riverpod
Stream<SidebarCounts> sidebarCounts(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  final inboxStream = db.inboxDao.watchInboxTasks();
  final todayStream = db.todayDao.watchTodayActiveItems(today);
  final eventsStream = db.eventsDao.watchUpcomingEvents();
  final deadlinesStream = db.deadlinesDao.watchActiveDeadlines();
  final projectsStream = db.projectsDao.watchAllProjects();

  return inboxStream.asyncExpand((inboxItems) async* {
    await for (final todayItems in todayStream) {
      await for (final events in eventsStream) {
        await for (final deadlines in deadlinesStream) {
          await for (final projects in projectsStream) {
            yield SidebarCounts(
              inboxCount: inboxItems.where((i) => !i.completed).length,
              todayCount: todayItems.length,
              eventsCount: events.where((e) => !e.item.completed).length,
              deadlinesCount: deadlines.where((d) => !d.item.completed).length,
              projectsCount: projects.where((p) => p.deletedAt == null).length,
            );
          }
        }
      }
    }
  });
}