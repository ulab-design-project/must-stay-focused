import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'data/db/isar_service.dart';
import 'data/db/supabase_client.dart';
import 'pages/home/home.dart';
import 'services/app_interception_service.dart';
import 'style/theme.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await LiquidGlassWidgets.initialize();
    await sdb.init();
    await IsarService().init();
    await AppInterceptionService().syncTrackedAppsFromDatabase();
  } catch (e, stackTrace) {
    debugPrint('App initialization error: $e');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }

  runApp(LiquidGlassWidgets.wrap(const MSF()));
}

class MSF extends StatelessWidget {
  const MSF({super.key});

  @override
  Widget build(BuildContext context) {
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
