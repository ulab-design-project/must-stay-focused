import 'package:flutter/material.dart';

import '../../style/containers.dart';
import '../../style/list_tile.dart';
import '../../style/theme.dart';
import '../introduction/interception_permissions_dialog.dart';

class PermissionsTile extends StatelessWidget {
  const PermissionsTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassListTile(
      leading: Container(height: 40, child: Icon(Icons.security, color: theme.colorScheme.primary)),
      title: Text(
        'App Interception Permissions',
        style: TextStyle(color: theme.colorScheme.onSurface),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: theme.colorScheme.onSurface,
        size: AppElementSizes.spacingSm,
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const InterceptionPermissionsDialog(),
        );
      },
    );
  }
}
