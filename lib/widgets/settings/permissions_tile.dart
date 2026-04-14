import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:must_stay_focused/style/theme.dart';
import 'package:must_stay_focused/widgets/introduction/interception_permissions_dialog.dart';

class PermissionsTile extends StatelessWidget {
  const PermissionsTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassCard(
      child: GlassListTile(
        leading: Icon(Icons.security, color: theme.colorScheme.primary),
        title: Text('App Interception Permissions', style: TextStyle(color: theme.colorScheme.onSurface)),
        trailing: Icon(Icons.arrow_forward_ios, color: theme.colorScheme.onSurface, size: AppElementSizes.spacingSm),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => const InterceptionPermissionsDialog(),
          );
        },
      ),
    );
  }
}

