import 'dart:async';
import 'dart:typed_data';

import 'package:background/background.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:must_stay_focused/style/theme.dart';

import '../../data/db/isar_service.dart';
import '../../data/models/app_usage.dart';
import '../../widgets/home/continue_to_app_dialog.dart';
import '../../widgets/home/default_home_app_bar.dart';
import '../../widgets/home/interception_home_app_bar.dart';
import '../../widgets/flashcard/flash_card_carousel.dart';
import '../challenge.dart';
import '../community/community_templates.dart';
import '../settings.dart';
import '../../style/background.dart';
import '../../widgets/challenge/math_challenge.dart';
import 'home_interception_controller.dart';
import 'tasks.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  final HomeInterceptionController _interceptionController =
      HomeInterceptionController();

  bool _interceptionMode = false;
  AppUsage? _interceptedApp;
  Uint8List? _interceptedAppIcon;
  bool _isInterceptedAppIconLoading = false;
  bool _isResolvingInterception = false;
  int _snapshotRequestVersion = 0;

  String? _suppressedAppId;
  DateTime? _suppressedAt;

  late final StreamSubscription<void> _dbSubscription;

  static const Duration _suppressionWindow = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _dbSubscription = idb.appUsages.watchLazy().listen((_) {
      _handleTrackedAppsChanged();
    });

    _checkPendingInterception();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dbSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingInterception();
    }
  }

  Future<void> _handleTrackedAppsChanged() async {
    await _interceptionController.syncTrackedApps();
    await _refreshInterceptedApp();
  }

  Future<void> _refreshInterceptedApp() async {
    final appId = _interceptedApp?.appId;
    if (appId == null || appId.isEmpty) {
      return;
    }

    await _applySnapshot(appId, enterInterceptionMode: _interceptionMode);
  }

  Future<void> _checkPendingInterception() async {
    if (_isResolvingInterception) {
      return;
    }

    _isResolvingInterception = true;

    try {
      final appId = await _interceptionController.consumeInterceptedAppId();
      if (appId == null || appId.isEmpty) {
        return;
      }

      if (_isSuppressed(appId)) {
        return;
      }

      await _applySnapshot(appId, enterInterceptionMode: true);
    } catch (e, stackTrace) {
      debugPrint('Home _checkPendingInterception error: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isResolvingInterception = false;
    }
  }

  Future<void> _applySnapshot(
    String appId, {
    required bool enterInterceptionMode,
  }) async {
    if (enterInterceptionMode && _isSuppressed(appId)) {
      return;
    }

    final int requestVersion = ++_snapshotRequestVersion;

    final snapshot = await _interceptionController.loadSnapshot(
      appId,
      includeIcon: false,
    );
    if (!mounted ||
        snapshot == null ||
        requestVersion != _snapshotRequestVersion) {
      return;
    }

    setState(() {
      _interceptedApp = snapshot.app;
      _interceptionMode = enterInterceptionMode;
      _interceptedAppIcon = null;
      _isInterceptedAppIconLoading = enterInterceptionMode;
    });

    if (enterInterceptionMode) {
      unawaited(_streamInterceptedAppIcon(appId, requestVersion));
    }
  }

  Future<void> _streamInterceptedAppIcon(
    String appId,
    int requestVersion,
  ) async {
    try {
      final iconBytes = await _interceptionController.loadAppIcon(appId);

      if (!mounted || requestVersion != _snapshotRequestVersion) {
        return;
      }

      if (_interceptedApp?.appId != appId || !_interceptionMode) {
        return;
      }

      setState(() {
        _interceptedAppIcon = iconBytes;
        _isInterceptedAppIconLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('Home _streamInterceptedAppIcon error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted || requestVersion != _snapshotRequestVersion) {
        return;
      }

      setState(() {
        _isInterceptedAppIconLoading = false;
      });
    }
  }

  bool _isSuppressed(String appId) {
    final suppressedAt = _suppressedAt;
    if (_suppressedAppId != appId || suppressedAt == null) {
      return false;
    }

    final active = DateTime.now().difference(suppressedAt) < _suppressionWindow;
    if (!active) {
      _suppressedAppId = null;
      _suppressedAt = null;
    }

    return active;
  }

  void _clearInterceptionState() {
    _snapshotRequestVersion++;

    setState(() {
      _interceptionMode = false;
      _interceptedApp = null;
      _interceptedAppIcon = null;
      _isInterceptedAppIconLoading = false;
    });
  }

  void _dismissInterception() {
    final appId = _interceptedApp?.appId;
    if (appId != null && appId.isNotEmpty) {
      _suppressedAppId = appId;
      _suppressedAt = DateTime.now();
    }

    _clearInterceptionState();
  }

  Future<void> _openTrackedApp(
    AppUsage app, {
    required int bypassMinutes,
  }) async {
    try {
      await _interceptionController.launchAppWithBypass(
        app: app,
        bypassMinutes: bypassMinutes,
      );

      if (!mounted) {
        return;
      }

      _clearInterceptionState();
    } catch (e, stackTrace) {
      debugPrint('Home _openTrackedApp error for ${app.appId}: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _onContinuePressed() async {
    final app = _interceptedApp;
    if (app == null) {
      return;
    }

    await _applySnapshot(app.appId, enterInterceptionMode: true);

    final latestApp = _interceptedApp;
    if (!mounted || latestApp == null) {
      return;
    }

    final defaultOvertimeLimitMinutes = await _interceptionController
        .getDefaultOvertimeLimitMinutes();

    final remainingMinutes = _interceptionController.remainingMinutes(
      latestApp,
      maxOvertimeMinutes: defaultOvertimeLimitMinutes,
    );
    final action = await showContinueToAppDialog(
      context,
      appName: latestApp.name,
      remainingMinutes: remainingMinutes,
      defaultOvertimeLimitMinutes: defaultOvertimeLimitMinutes,
    );

    if (!mounted || action == ContinueToAppAction.stayFocused) {
      return;
    }

    if (action == ContinueToAppAction.openSettings) {
      _dismissInterception();
      await _openSettings();
      return;
    }

    if (action == ContinueToAppAction.challenge) {
      final solved = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ChallengePage(
            appUsage: latestApp,
            appIconBytes: _interceptedAppIcon,
            difficulty: DifficultySettings.easy,
          ),
        ),
      );

      if (solved == true && mounted) {
        _clearInterceptionState();
      }
      return;
    }

    final bypassMinutes = _interceptionController.continueBypassMinutes(
      latestApp,
      maxOvertimeMinutes: defaultOvertimeLimitMinutes,
    );
    await _openTrackedApp(latestApp, bypassMinutes: bypassMinutes);
  }

  Future<void> _debugTriggerInterception() async {
    try {
      final tracked = (await _interceptionController.getTrackedApps())
          .where((app) => app.isTracked)
          .toList();

      if (tracked.isEmpty) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No tracked app available for debug mode.'),
          ),
        );
        return;
      }

      await _applySnapshot(tracked.first.appId, enterInterceptionMode: true);
    } catch (e, stackTrace) {
      debugPrint('Home _debugTriggerInterception error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }

  Future<void> _openCommunityTemplates() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CommunityTemplatesPage()),
      );
    } catch (e, stackTrace) {
      debugPrint('Home _openCommunityTemplates error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundDrop(
      scaffold: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _interceptionMode
            ? InterceptionHomeAppBar(
                appIconBytes: _interceptedAppIcon,
                isAppIconLoading: _isInterceptedAppIconLoading,
                onBackPressed: _dismissInterception,
                onContinuePressed: _interceptedApp == null
                    ? null
                    : _onContinuePressed,
              )
            : DefaultHomeAppBar(
                showDebugInterceptionButton: kDebugMode,
                onDebugInterception: _debugTriggerInterception,
                onStorePressed: _openCommunityTemplates,
                onSettingsPressed: _openSettings,
              ),
        body: const Stack(
          children: [
            TasksPage(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FlashCardCarousel(),
            ),
          ],
        ),
      ),
    );
    // return Scaffold(
    //     // backgroundColor: Colors.transparent,
    //     appBar: _interceptionMode
    //         ? InterceptionHomeAppBar(
    //             appIconBytes: _interceptedAppIcon,
    //             isAppIconLoading: _isInterceptedAppIconLoading,
    //             onBackPressed: _dismissInterception,
    //             onContinuePressed: _interceptedApp == null
    //                 ? null
    //                 : _onContinuePressed,
    //           )
    //         : DefaultHomeAppBar(
    //             showDebugInterceptionButton: kDebugMode,
    //             onDebugInterception: _debugTriggerInterception,
    //             onStorePressed: _openCommunityTemplates,
    //             onSettingsPressed: _openSettings,
    //           ),
    //     body: Background(
    //       path: Backgrounds.iridescent,
    //       child: const Stack(
    //         children: [
    //           TasksPage(),
    //           Positioned(
    //             bottom: 0,
    //             left: 0,
    //             right: 0,
    //             child: FlashCardCarousel(),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
  }
}
