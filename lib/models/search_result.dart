import 'item.dart';

class SearchResult {
  const SearchResult({
    required this.item,
    required this.score,
    this.startDate,
    this.endDate,
    this.projectName,
  });

  final Item item;
  final double score;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? projectName;
}
