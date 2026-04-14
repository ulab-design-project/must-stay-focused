import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app_interception_service.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();
  
  static const MethodChannel _channel = MethodChannel('must_stay_focused_permissions');

  /// Requests Notification permissions
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Checks if Notification permission is granted
  Future<bool> isNotificationGranted() async {
    return await Permission.notification.isGranted;
  }

  /// Checks if Usage Access is granted silently via native channel
  Future<bool> isUsageAccessGranted() async {
    try {
      final bool result = await _channel.invokeMethod('checkUsageAccess');
      return result;
    } catch (e) {
      return false;
    }
  }

  /// System Alert Window / Overlay
  Future<bool> requestOverlayPermission() async {
    return (await Permission.systemAlertWindow.request()).isGranted;
  }

  /// Accessibility service toggle used for real-time app interception.
  Future<bool> isAccessibilityServiceEnabled() async {
    return AppInterceptionService().isAccessibilityServiceEnabled();
  }

  /// Opens Android accessibility settings so users can enable interception.
  Future<void> openAccessibilitySettings() async {
    await AppInterceptionService().openAccessibilitySettings();
  }
}
