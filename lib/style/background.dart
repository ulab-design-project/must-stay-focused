import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
        // Positioned(child: Container(color: primaryColor,width: screenWidth,height: 100,),top: screenHeight * 0.5,),
        const _LoopingBackgroundVideo(),
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

class _LoopingBackgroundVideo extends StatefulWidget {
  const _LoopingBackgroundVideo();

  @override
  State<_LoopingBackgroundVideo> createState() =>
      _LoopingBackgroundVideoState();
}

class _LoopingBackgroundVideoState extends State<_LoopingBackgroundVideo>
    with WidgetsBindingObserver {
  static VideoPlayerController? _controller;
  static Future<void>? _initFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initVideo();
  }

  Future<void> _initVideo() async {
    if (_controller == null) {
      _controller = VideoPlayerController.asset(
        'assets/bgvid/3.mp4', //TODO bg video
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      _initFuture = _controller!
          .initialize()
          .then((_) async {
            await _controller!.setLooping(true);
            await _controller!.setVolume(0);
            await _controller!.play();
          })
          .catchError((e, stackTrace) {
            debugPrint('Background video initialization failed: $e');
          });
    }

    if (_initFuture != null) {
      await _initFuture;
    }

    if (mounted) setState(() {});
    _controller?.play(); // Ensure it's playing when returning to screen
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Note: Intentionally not disposing _controller so the video stays loaded and loops continuously across app navigation.
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller?.play();
    } else if (state == AppLifecycleState.paused) {
      _controller?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    // const double darkBrightness = 0.4; // 0.0 is completely black, 1.0 is full brightness

    Widget videoWidget = Transform.rotate(
      angle: math.pi / 2,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller!.value.size.width,
          height: _controller!.value.size.height,
          child: VideoPlayer(_controller!),
        ),
      ),
    );

    videoWidget = ColorFiltered(
      colorFilter: theme.brightness == Brightness.light
          ? ColorFilter.mode(
              theme.colorScheme.secondary.withValues(alpha: 0.6),
              BlendMode.hardLight,
            )
          : ColorFilter.mode(
              theme.colorScheme.primary.withValues(alpha: 0.8),
              BlendMode.multiply,
            ),
      child: videoWidget,
    );

    return Positioned.fill(child: IgnorePointer(child: videoWidget));
  }
}
