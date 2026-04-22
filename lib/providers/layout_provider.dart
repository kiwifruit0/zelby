import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'layout_provider.g.dart';
part 'layout_provider.freezed.dart';

@freezed
abstract class LayoutStateData with _$LayoutStateData {
  const factory LayoutStateData({@Default(true) bool sidebarVisible}) = _LayoutStateDataImpl;
}

@riverpod
class LayoutNotifier extends _$LayoutNotifier {
  @override
  LayoutStateData build() => const LayoutStateData();

  void toggleSidebar() {
    state = state.copyWith(sidebarVisible: !state.sidebarVisible);
  }
}