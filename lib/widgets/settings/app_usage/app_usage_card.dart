import 'package:flutter/material.dart';
import 'dart:typed_data';

import '../../../data/models/app_usage.dart';
import '../../../style/buttons.dart';
import '../../../style/list_tile.dart';
import '../../../style/theme.dart';
import 'app_usage_data.dart';

class AppUsageCard extends StatelessWidget {
  final AppUsage appUsage;
  final int usageTodayMins;
  final Uint8List? iconBytes;
  final VoidCallback onUntrack;

  const AppUsageCard({
    super.key,
    required this.appUsage,
    required this.usageTodayMins,
    required this.iconBytes,
    required this.onUntrack,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = AppElementSizes.buttonSquare;
    final iconCacheSize = (iconSize * MediaQuery.devicePixelRatioOf(context))
        .round();
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return GlassListTile(
      leading: iconBytes != null
          ? Image.memory(
              iconBytes!,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.contain,
              cacheWidth: iconCacheSize,
              cacheHeight: iconCacheSize,
              filterQuality: FilterQuality.low,
            )
          : const Icon(Icons.android, color: Colors.green),
      title: Text(appUsage.name, style: TextStyle(color: onSurface)),
      subtitle: Text(
        'Usage today: $usageTodayMins mins',
        style: TextStyle(color: onSurface.withValues(alpha: 0.7)),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GlassSquircleIconButton(
            icon: Icon(Icons.info_outline, color: onSurface),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AppUsageDataDialog(appUsage: appUsage),
              );
            },
          ),
          const SizedBox(width: AppElementSizes.spacingSm),
          GlassSquircleIconButton(
            icon: Icon(Icons.delete_outline, color: onSurface),
            onPressed: onUntrack,
          ),
        ],
      ),
    );
  }
}
