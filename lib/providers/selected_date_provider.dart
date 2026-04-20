import 'package:flutter_riverpod/legacy.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
