import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:sqflite/sqflite.dart';

import '../model/repositories/game_database.dart';
import 'game_screen.dart';
import 'game_setting_dialog.dart';
import 'widgets/widget_text.dart';

class SplashScreen extends StatefulWidget {
  final Database database;

  const SplashScreen({required this.database, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _atgText = '';
  String _mathsPointsGameText = '';
  final String _fullAtgText = 'ATG';
  final String _fullMathsPointsGameText = 'Maths points game';

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () {
      _animateText();
    });
    Timer(const Duration(seconds: 4), () {
      _checkAndNavigate();
    });
  }

  Future<void> _checkAndNavigate() async {
    final lastState = await GameDatabase.loadLastGameState(widget.database);
    if (!mounted) return;

    if (lastState != null && !lastState.isGameOver) {
      // Game in progress - go directly to game screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameScreen(database: widget.database),
        ),
      );
    } else {
      // No game in progress or game is over - show settings
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameSettingsDialog(database: widget.database),
        ),
      );
    }
  }

  void _animateText() {
    // Animation de "ATG" sur 2 secondes
    var atgDuration = const Duration(milliseconds: 2000);
    var atgInterval = atgDuration.inMilliseconds ~/ _fullAtgText.length;

    for (var i = 0; i < _fullAtgText.length; i++) {
      Timer(Duration(milliseconds: i * atgInterval), () {
        setState(() {
          _atgText = _fullAtgText.substring(0, i + 1);
        });
      });
    }

    // Animation de "Maths points game" sur 1 seconde, commençant après "ATG"
    var mathsPointsGameDuration = const Duration(milliseconds: 1000);
    var mathsPointsGameInterval = mathsPointsGameDuration.inMilliseconds ~/
        _fullMathsPointsGameText.length;

    for (var i = 0; i < _fullMathsPointsGameText.length; i++) {
      Timer(Duration(milliseconds: 2000 + (i * mathsPointsGameInterval)), () {
        setState(() {
          _mathsPointsGameText = _fullMathsPointsGameText.substring(0, i + 1);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo GIF
            GifView.asset(
              'assets/maths_points_game_logo.gif',
              width: 200, // Ajustez selon la taille souhaitée
              height: 200, // Ajustez selon la taille souhaitée
              frameRate: 20, // Ajustez selon les besoins
            ),
            const SizedBox(height: 40),
            // Textes animés
            GradientText(
              _atgText,
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 0, 0),
                  Color.fromARGB(255, 0, 30, 255)
                ],
              ),
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              _mathsPointsGameText,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
