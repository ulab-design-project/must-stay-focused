import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:must_stay_focused/style/theme.dart';

import '../utils/theme_helpers.dart';

/// Background wrapper with gradient circles.
///
/// Provides the glass-morphism style background with gradient circles
/// and transparent content scaffold. No blur filter (performance).
class BackgroundDrop extends StatelessWidget {
  final Scaffold scaffold;
  final double circleOpacity;

  const BackgroundDrop({
    super.key,
    required this.scaffold,
    this.circleOpacity = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final primaryColor = theme.primaryColor;

    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);

    return Stack(
      children: [
        // Base BG
        Container(width: screenWidth, height: screenHeight, color: bgColor),
        // Big Circle (top left)
        Positioned(
          top: -screenWidth,
          left: -screenWidth,
          child: Container(
            width: screenWidth * 2,
            height: screenWidth * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: circleOpacity),
            ),
          ),
        ),
        // Small Circle (bottom center)
        Positioned(
          top: screenHeight - 0.25 * screenWidth,
          left: screenWidth / 2 - 0.5 * screenWidth,
          child: Container(
            width: screenWidth,
            height: screenWidth,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: circleOpacity),
            ),
          ),
        ),

        // Background blur
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: GlassEffects.blurSigma, sigmaY: GlassEffects.blurSigma),
          child: Container(
            width: screenWidth,
            height: screenHeight,
            color: Colors.transparent,
          ),
        ),
        // Content (Glass Scaffold)
        Theme(
          data: theme.copyWith(
            scaffoldBackgroundColor: Colors.transparent,
            appBarTheme: theme.appBarTheme.copyWith(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          child: Scaffold(
            key: scaffold.key,
            appBar: scaffold.appBar,
            body: scaffold.body,
            floatingActionButton: scaffold.floatingActionButton,
            floatingActionButtonLocation: scaffold.floatingActionButtonLocation,
            floatingActionButtonAnimator: scaffold.floatingActionButtonAnimator,
            persistentFooterButtons: scaffold.persistentFooterButtons,
            persistentFooterAlignment: scaffold.persistentFooterAlignment,
            drawer: scaffold.drawer,
            onDrawerChanged: scaffold.onDrawerChanged,
            endDrawer: scaffold.endDrawer,
            onEndDrawerChanged: scaffold.onEndDrawerChanged,
            bottomNavigationBar: scaffold.bottomNavigationBar,
            bottomSheet: scaffold.bottomSheet,
            backgroundColor: Colors.transparent,
            resizeToAvoidBottomInset: scaffold.resizeToAvoidBottomInset,
            primary: scaffold.primary,
            drawerDragStartBehavior: scaffold.drawerDragStartBehavior,
            extendBody: scaffold.extendBody,
            extendBodyBehindAppBar: scaffold.extendBodyBehindAppBar,
            drawerScrimColor: scaffold.drawerScrimColor,
            drawerEdgeDragWidth: scaffold.drawerEdgeDragWidth,
            drawerEnableOpenDragGesture: scaffold.drawerEnableOpenDragGesture,
            endDrawerEnableOpenDragGesture:
                scaffold.endDrawerEnableOpenDragGesture,
            restorationId: scaffold.restorationId,
          ),
        ),
      ],
    );
  }
}
