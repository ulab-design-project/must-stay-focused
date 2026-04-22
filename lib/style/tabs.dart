import 'package:flutter/material.dart';

import 'containers.dart';
import 'theme.dart';

/// Glass-styled TabBar.
///
/// A TabBar with glass surface styling. Requires a TabController.
class GlassTabBar extends StatelessWidget {
  final double height;
  final Color? indicatorColor;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;
  final List<Tab> tabs;
  final TabController? controller;
  final ValueChanged<int>? onTabSelected;

  const GlassTabBar({
    super.key,
    this.height = 56,
    this.indicatorColor,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
    required this.tabs,
    this.controller,
    this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final selectedColor = selectedIconColor ?? colorScheme.onSurface;
    final unselectedColor =
        unselectedIconColor ?? colorScheme.onSurface.withValues(alpha: 0.75);
    final indicator =
        indicatorColor ?? colorScheme.secondary.withValues(alpha: 0.5);

    return GlassCard(
      isPrimary: false,
      margin: EdgeInsets.zero,
      child: SizedBox(
        height: height,
        child: TabBar(
          controller: controller,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: indicator, width: 2),
            insets: const EdgeInsets.symmetric(horizontal: 16),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: tabs,
          onTap: onTabSelected,
          labelColor: selectedColor,
          unselectedLabelColor: unselectedColor,
          labelStyle:
              selectedLabelStyle ??
              const TextStyle(
                fontSize: AppTextSizes.small,
                fontWeight: FontWeight.w600,
              ),
          unselectedLabelStyle:
              unselectedLabelStyle ??
              const TextStyle(fontSize: AppTextSizes.small),
        ),
      ),
    );
  }
}

/// Glass-styled Tab widget for use with GlassTabBar.
class GlassTab extends Tab {
  const GlassTab({super.key, required String label, Widget? icon})
    : super(text: label, icon: icon);
}
