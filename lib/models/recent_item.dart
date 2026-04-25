enum RecentItemType { item, route }

class RecentItem {
  const RecentItem({
    required this.id,
    required this.type,
    this.itemId,
    this.route,
    required this.title,
    this.subtitle,
    required this.iconKind, // item type or icon name
    required this.updatedAt,
  });

  final int id;
  final RecentItemType type;
  final int? itemId;
  final String? route;
  final String title;
  final String? subtitle;
  final String iconKind;
  final DateTime updatedAt;
}
