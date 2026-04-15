import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'data/db/isar_service.dart';
import 'data/db/supabase_client.dart';
import 'pages/home/home.dart';
import 'services/app_interception_service.dart';
import 'style/theme.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('FlutterError: ${details.exceptionAsString()}');
    debugPrintStack(stackTrace: details.stack);
  };

  Object? initError;
  StackTrace? initStackTrace;
  var liquidGlassReady = false;

  try {
    await LiquidGlassWidgets.initialize();
    liquidGlassReady = true;
    await sdb.init();
    await IsarService().init();
    await AppInterceptionService().syncTrackedAppsFromDatabase();
  } catch (e, stackTrace) {
    debugPrint('App initialization error: $e');
    debugPrintStack(stackTrace: stackTrace);
    initError = e;
    initStackTrace = stackTrace;
  }

  final app = MSF(
    initError: initError,
    initStackTrace: initStackTrace,
  );

  if (liquidGlassReady) {
    runApp(LiquidGlassWidgets.wrap(app));
  } else {
    runApp(app);
  }
}

class MSF extends StatelessWidget {
  final Object? initError;
  final StackTrace? initStackTrace;

  const MSF({
    super.key,
    this.initError,
    this.initStackTrace,
  });

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return MaterialApp(
        title: 'Must Stay Focused',
        debugShowCheckedModeBanner: false,
        home: _StartupErrorScreen(
          error: initError!,
          stackTrace: initStackTrace,
        ),
      );
    }

    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final app = MaterialApp(
          navigatorKey: appNavigatorKey,
          title: 'Must Stay Focused',
          debugShowCheckedModeBanner: false,
          theme: themeController.currentTheme,
          home: const Home(),
        );

        return GlassTheme(
          data: themeController.currentGlassTheme,
          child: GlassMotionScope(
            lightAngle: themeController.gyroscopeLightAngleStream,
            child: app,
          ),
        );
      },
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const _StartupErrorScreen({
    required this.error,
    this.stackTrace,
  });

  @override
  Widget build(BuildContext context) {
    final stackTraceText = stackTrace?.toString() ?? 'No stack trace available.';
    final copyText = 'Startup failed\n\nError:\n${error.toString()}\n\nStack trace:\n$stackTraceText';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Startup failed',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                const Text(
                  'The app could not initialize. Check your build-time dart defines (for example SUPABASE_URL and SUPABASE_ANON_KEY).',
                ),
                const SizedBox(height: 16),
                Text(
                  error.toString(),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: copyText));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Stack trace copied')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy stack trace'),
                ),
                if (stackTrace != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    stackTrace.toString(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
