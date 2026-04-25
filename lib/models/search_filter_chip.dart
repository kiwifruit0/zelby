import 'package:flutter/material.dart';

class SearchFilterChip {
  const SearchFilterChip({
    required this.id,
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String id;
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
}