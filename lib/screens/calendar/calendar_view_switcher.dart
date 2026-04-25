import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

enum CalendarView { daily, weekly, monthly }

class CalendarViewSwitcher extends StatelessWidget {
  const CalendarViewSwitcher({super.key, required this.currentView});

  final CalendarView currentView;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.divider),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewButton(
            label: 'Daily',
            route: '/calendar/daily',
            isActive: currentView == CalendarView.daily,
          ),
          _ViewButton(
            label: 'Weekly',
            route: '/calendar/weekly',
            isActive: currentView == CalendarView.weekly,
          ),
          _ViewButton(
            label: 'Monthly',
            route: '/calendar/monthly',
            isActive: currentView == CalendarView.monthly,
          ),
        ],
      ),
    );
  }
}

class _ViewButton extends StatelessWidget {
  const _ViewButton({
    required this.label,
    required this.route,
    required this.isActive,
  });

  final String label;
  final String route;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isActive ? null : () => context.go(route),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.itemMeta.copyWith(
            color: isActive ? AppColors.primary : AppColors.muted,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
