import 'package:flutter/material.dart';
import '../models/search_command.dart';

class NavigationRegistry {
  static const List<SearchCommand> commands = [
    SearchCommand(
      id: 'home',
      title: 'Home',
      icon: Icons.home_outlined,
      route: '/today',
      keywords: ['today', 'home', 'main'],
      isDefault: true,
    ),
    SearchCommand(
      id: 'inbox',
      title: 'Inbox',
      icon: Icons.inbox_outlined,
      route: '/inbox',
      keywords: ['inbox', 'tasks', 'unscheduled'],
      isDefault: true,
    ),
    SearchCommand(
      id: 'calendar',
      title: 'Calendar',
      icon: Icons.calendar_today_outlined,
      route: '/calendar',
      keywords: ['calendar', 'events', 'schedule'],
      isDefault: true,
    ),
    SearchCommand(
      id: 'upcoming',
      title: 'Upcoming',
      icon: Icons.schedule_outlined,
      route: '/upcoming',
      keywords: ['upcoming', 'scheduled', 'future'],
      isDefault: true,
    ),
    SearchCommand(
      id: 'projects',
      title: 'Projects',
      icon: Icons.folder_outlined,
      route: '/projects',
      keywords: ['projects', 'lists'],
      isDefault: true,
    ),
    SearchCommand(
      id: 'events-deadlines',
      title: 'Events & Deadlines',
      icon: Icons.access_time,
      route: '/events-deadlines',
      keywords: ['events', 'deadlines', 'dates'],
      isDefault: true,
    ),
  ];
}
