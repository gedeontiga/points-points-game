import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';
import '../core/services/game_database.dart';
import '../core/services/game_notifier.dart';
import '../core/widgets/widget_text.dart';
import '../main.dart';
import 'game_screen.dart';
import 'game_settings_dialog.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _textAnimationController;
  late final Animation<int> _atgTextAnimation;
  late final Animation<int> _mathsPointsGameTextAnimation;

  final String _fullAtgText = 'ATG';
  final String _fullMathsPointsGameText = 'Squares Conquest';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeNavigation();
  }

  void _initializeAnimations() {
    _textAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _atgTextAnimation = IntTween(begin: 0, end: _fullAtgText.length).animate(
      CurvedAnimation(
          parent: _textAnimationController, curve: const Interval(0.0, 0.5)),
    );

    _mathsPointsGameTextAnimation =
        IntTween(begin: 0, end: _fullMathsPointsGameText.length).animate(
      CurvedAnimation(
          parent: _textAnimationController, curve: const Interval(0.5, 1.0)),
    );

    _textAnimationController.forward();
  }

  // *** THIS METHOD IS NOW FIXED ***
  Future<void> _initializeNavigation() async {
    // 1. Define a minimum time for the splash screen to be visible.
    Future<void> minimumWait = Future.delayed(const Duration(seconds: 4));

    // 2. Perform the database check to decide the destination screen.
    Future<Widget> destinationFuture = _getDestinationScreen();

    // 3. Wait for BOTH futures to complete. Future.wait returns a list of results.
    List<dynamic> results = await Future.wait([minimumWait, destinationFuture]);

    // 4. Extract the destination widget from the results. It's the second item.
    final Widget destinationScreen = results[1];

    if (!mounted) return;

    // 5. Navigate to the correct screen using the resolved widget. No 'await' needed here.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => destinationScreen),
    );
  }

  Future<Widget> _getDestinationScreen() async {
    final db = await ref.read(databaseProvider.future);
    final lastState = await GameDatabase.loadLastGameState(db);

    if (lastState != null && !lastState.isGameOver) {
      // If there's a game to restore, load it into the provider
      await ref.read(gameProvider.notifier).loadGame(db);
      return GameScreen(database: db);
    } else {
      // Otherwise, the destination is the settings dialog
      return GameSettingsDialog(database: db);
    }
  }

  @override
  void dispose() {
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GifView.asset(
              'assets/maths_points_game_logo.gif',
              width: 200,
              height: 200,
              frameRate: 20,
            ),
            const SizedBox(height: 40),
            AnimatedBuilder(
              animation: _atgTextAnimation,
              builder: (context, child) {
                return GradientText(
                  _fullAtgText.substring(0, _atgTextAnimation.value),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 255, 0, 0),
                      Color.fromARGB(255, 0, 30, 255)
                    ],
                  ),
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold),
                );
              },
            ),
            const SizedBox(height: 5),
            AnimatedBuilder(
              animation: _mathsPointsGameTextAnimation,
              builder: (context, child) {
                return Text(
                  _fullMathsPointsGameText.substring(
                      0, _mathsPointsGameTextAnimation.value),
                  style: const TextStyle(fontSize: 24, color: Colors.black87),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
