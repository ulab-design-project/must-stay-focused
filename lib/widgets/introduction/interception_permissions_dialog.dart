import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/permission_service.dart';
import '../../services/appUsageMonitor/android_app_usage.dart';
import '../../style/theme.dart';

class InterceptionPermissionsDialog extends StatefulWidget {
  const InterceptionPermissionsDialog({super.key});

  @override
  State<InterceptionPermissionsDialog> createState() => _InterceptionPermissionsDialogState();
}

class _InterceptionPermissionsDialogState extends State<InterceptionPermissionsDialog> with WidgetsBindingObserver {
  bool _notificationsEnabled = false;
  bool _usageEnabled = false; 
  bool _accessibilityEnabled = false;
  bool _overlayEnabled = false;
  bool _batteryOptEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-evaluate permissions after returning from Android Settings
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final notif = await PermissionService().isNotificationGranted();
    final overlay = await Permission.systemAlertWindow.isGranted;
    final battery = await Permission.ignoreBatteryOptimizations.isGranted;
    final usage = await PermissionService().isUsageAccessGranted();
    final accessibility = await PermissionService().isAccessibilityServiceEnabled();

    setState(() {
      _notificationsEnabled = notif;
      _overlayEnabled = overlay;
      _batteryOptEnabled = battery;
      _usageEnabled = usage;
      _accessibilityEnabled = accessibility;
    });
  }

  Future<void> _requestNotification() async {
    final granted = await PermissionService().requestNotificationPermission();
    setState(() {
      _notificationsEnabled = granted;
    });
  }

  Future<void> _requestOverlay() async {
    final status = await Permission.systemAlertWindow.request();
    setState(() {
      _overlayEnabled = status.isGranted;
    });
  }

  Future<void> _requestBattery() async {
    final status = await Permission.ignoreBatteryOptimizations.request();
    setState(() {
      _batteryOptEnabled = status.isGranted;
    });
  }

  Future<void> _requestUsage() async {
    await AndroidAppUsageMonitor().requestUsagePermissions();
  }

  Future<void> _requestAccessibility() async {
    await PermissionService().openAccessibilitySettings();
  }

  @override
  Widget build(BuildContext context) {
    return GlassDialog(
      title: "Enable Interception",
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "We need the following permissions to track and limit your app usage.",
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppElementSizes.spacingLg * 1.5),
          _buildPermissionTile(
            title: "Accessibility Service",
            enabled: _accessibilityEnabled,
            onTap: _requestAccessibility,
          ),
          const SizedBox(height: AppElementSizes.spacingMd),
          _buildPermissionTile(
            title: "App Usage Access",
            enabled: _usageEnabled,
            onTap: _requestUsage,
          ),
          const SizedBox(height: AppElementSizes.spacingMd),
          _buildPermissionTile(
            title: "Notifications",
            enabled: _notificationsEnabled,
            onTap: _requestNotification,
          ),
          const SizedBox(height: AppElementSizes.spacingMd),
          _buildPermissionTile(
            title: "Draw Over Other Apps",
            enabled: _overlayEnabled,
            onTap: _requestOverlay,
          ),
          const SizedBox(height: AppElementSizes.spacingMd),
          _buildPermissionTile(
            title: "Run in Background",
            enabled: _batteryOptEnabled,
            onTap: _requestBattery,
          ),
        ],
      ),
      actions: [
        GlassDialogAction(
          label: "Done",
          isPrimary: true,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildPermissionTile({required String title, required bool enabled, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(AppElementSizes.cardRadius),
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: enabled
            ? const Icon(Icons.check_circle, color: Colors.white)
            : const Icon(Icons.radio_button_unchecked, color: Colors.white54),
        onTap: enabled ? null : onTap,
      ),
    );
  }
}
