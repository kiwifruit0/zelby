import 'package:flutter/material.dart';

enum CommandType { navigation, action }

class SearchCommand {
  const SearchCommand({
    required this.id,
    required this.title,
    this.subtitle,
    required this.icon,
    this.route,
    this.onTap,
    this.keywords = const [],
    this.isDefault = false,
    this.type = CommandType.navigation,
  });

  final String id;
  final String title;
  final String? subtitle;
  final IconData icon;
  final String? route;
  final VoidCallback? onTap;
  final List<String> keywords;
  final bool isDefault;
  final CommandType type;
}
