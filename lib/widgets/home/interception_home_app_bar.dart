import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../style/buttons.dart';
import '../../style/theme.dart';

class InterceptionHomeAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final Uint8List? appIconBytes;
  final bool isAppIconLoading;
  final VoidCallback onBackPressed;
  final VoidCallback? onContinuePressed;

  const InterceptionHomeAppBar({
    super.key,
    required this.appIconBytes,
    required this.isAppIconLoading,
    required this.onBackPressed,
    required this.onContinuePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final iconSize = AppElementSizes.icon;
    final iconCacheSize = (iconSize * MediaQuery.devicePixelRatioOf(context))
        .round();

    Widget appIcon;
    if (isAppIconLoading) {
      appIcon = SizedBox(
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(strokeWidth: 2, color: onSurface),
      );
    } else if (appIconBytes != null) {
      appIcon = Image.memory(
        appIconBytes!,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        cacheWidth: iconCacheSize,
        cacheHeight: iconCacheSize,
        filterQuality: FilterQuality.low,
      );
    } else {
      appIcon = Icon(Icons.android, color: onSurface, size: iconSize);
    }

    return AppBar(
      title: Text('Review Tasks', style: TextStyle(color: onSurface)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 64,
      leading: Align(
        alignment: Alignment.centerRight,
        child: GlassSquircleIconButton(
          icon: Icon(Icons.arrow_back, color: onSurface),
          onPressed: onBackPressed,
          size: AppElementSizes.buttonSquare,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GlassSquircleButton(
            onPressed: onContinuePressed,
            width: 124,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                appIcon,
                const SizedBox(width: AppElementSizes.spacingSm),
                Text(
                  'Continue',
                  style: TextStyle(color: onSurface),
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
