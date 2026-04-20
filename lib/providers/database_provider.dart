import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/database.dart';

part 'database_provider.g.dart';

@riverpod
AppDatabase appDatabase(Ref ref) {
  return AppDatabase.instance;
}
