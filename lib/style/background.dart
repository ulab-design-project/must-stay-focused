import 'dart:ui';
import 'package:flutter/material.dart';

import '../utils/theme_helpers.dart';

// TODO: Convert to liquid glass widgets.

class BackgroundDrop extends StatelessWidget {
  final Scaffold scaffold;
  final double filterStrength = 70.0;
  final double circleOpacity = 0.6;

  const BackgroundDrop({super.key, required this.scaffold});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.scaffoldBackgroundColor;
    final primaryColor = theme.primaryColor;

    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);

    return Stack(
      children: [
        // Base BG Box
        Container(width: screenWidth, height: screenHeight, color: bgColor),
        // Big Circle (top left, so only bottom right piece is visible)
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
        // Small Circle (bottom center, top 1/4 visible)
        // center at bottom center - 0.25 screenWidth means its center is at y = screenHeight - 0.25 * screenWidth
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
        // Blur Filter
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: filterStrength,
              sigmaY: filterStrength,
            ),
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          child: Container(color: primaryColor, width: screenWidth, height: 100,),
          top: screenHeight * 0.5,
        ),

        // TODO: Convert to liquid glass widgets.
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
            backgroundColor: Colors.transparent, // force transparent bg
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
