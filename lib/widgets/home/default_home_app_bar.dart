import 'package:flutter/material.dart';

import '../../style/buttons.dart';

class DefaultHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showDebugInterceptionButton;
  final VoidCallback onDebugInterception;
  final VoidCallback onStorePressed;
  final VoidCallback onSettingsPressed;

  const DefaultHomeAppBar({
    super.key,
    required this.showDebugInterceptionButton,
    required this.onDebugInterception,
    required this.onStorePressed,
    required this.onSettingsPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return AppBar(
      title: Text(
        'Tasks',
        style: TextStyle(color: onSurface),
      ),
      elevation: 0,
      actions: [
        if (showDebugInterceptionButton)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: GlassSquircleIconButton(
              icon: Icon(Icons.code, color: onSurface),
              onPressed: onDebugInterception,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GlassSquircleIconButton(
            icon: Icon(Icons.store, color: onSurface),
            onPressed: onStorePressed,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GlassSquircleIconButton(
            icon: Icon(Icons.settings, color: onSurface),
            onPressed: onSettingsPressed,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
