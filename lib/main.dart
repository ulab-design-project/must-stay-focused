import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'data/db/isar_service.dart';
import 'pages/home/home.dart';
import 'style/theme.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await LiquidGlassWidgets.initialize();
    await IsarService().init();
  } catch (e) {
    debugPrint('App initialization error: $e');
    // debugPrintStack(stackTrace: stackTrace);
    // rethrow;
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
