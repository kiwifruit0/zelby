import 'package:flutter/material.dart';
import '../../models/search_filter_chip.dart';
import 'filter_chip.dart';

class FilterChipRow extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.chips,
  });

  final List<SearchFilterChip> chips;

  @override
  Widget build(BuildContext context) {
    if (chips.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: chips.map((chip) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SearchFilterChipWidget(
              label: chip.label,
              isSelected: chip.isSelected,
              onTap: chip.onTap,
              icon: chip.icon,
            ),
          );
        }).toList(),
      ),
    );
  }
}