import 'package:flutter/material.dart';

import '../../style/dialogs.dart';

enum ContinueToAppAction { stayFocused, openSettings, challenge, continueToApp }

Future<ContinueToAppAction> showContinueToAppDialog(
  BuildContext context, {
  required String appName,
  required int remainingMinutes,
  required int defaultOvertimeLimitMinutes,
}) async {
  final bool overtimeBlocked = defaultOvertimeLimitMinutes <= 0;

  final ContinueToAppAction primaryAction;
  final String primaryLabel;
  final String message;

  if (overtimeBlocked) {
    primaryAction = ContinueToAppAction.openSettings;
    primaryLabel = 'Settings';
    message = 'Overtime limit is blocked';
  } else if (remainingMinutes <= 0) {
    primaryAction = ContinueToAppAction.challenge;
    primaryLabel = 'Challenge';
    message = 'You have 0 minutes left';
  } else {
    primaryAction = ContinueToAppAction.continueToApp;
    primaryLabel = 'Continue';
    final suffix = remainingMinutes == 1 ? 'minute' : 'minutes';
    message = 'You have $remainingMinutes $suffix left';
  }

  final selected = await showDialog<ContinueToAppAction>(
    context: context,
    builder: (context) {
      return GlassDialog(
        title: 'Continue to $appName',
        content: Text(
          message,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
        actions: [
          
          GlassDialogAction(
            label: primaryLabel,
            onPressed: () => Navigator.pop(context, primaryAction),
          ),
          GlassDialogAction(
            label: 'Stay Focused',
            isPrimary: true,
            onPressed: () =>
                Navigator.pop(context, ContinueToAppAction.stayFocused),
          ),
        ],
      );
    },
  );

  return selected ?? ContinueToAppAction.stayFocused;
}
