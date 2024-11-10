import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gif_view/gif_view.dart';
import 'package:sqflite/sqflite.dart';

import '../widgets/game_setting_dialog.dart';
import '../widgets/widget_text.dart';

class SplashScreen extends StatefulWidget {
  final Database database;

  const SplashScreen({required this.database, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _atgText = '';
  String _blocusText = '';
  final String _fullAtgText = 'ATG';
  final String _fullBlocusText = 'blocus game';

  @override
  void initState() {
    super.initState();

    // Planifier l'apparition du texte après 3 secondes
    Timer(const Duration(seconds: 3), () {
      _animateText();
    });

    // Naviguer vers la page de configuration après 6 secondes
    Timer(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => GameSettingsDialog(database: widget.database),
        ),
      );
    });
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

    // Animation de "blocus game" sur 1 seconde, commençant après "ATG"
    var blocusDuration = const Duration(milliseconds: 1000);
    var blocusInterval =
        blocusDuration.inMilliseconds ~/ _fullBlocusText.length;

    for (var i = 0; i < _fullBlocusText.length; i++) {
      Timer(Duration(milliseconds: 2000 + (i * blocusInterval)), () {
        setState(() {
          _blocusText = _fullBlocusText.substring(0, i + 1);
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
              'assets/blocus_logo.gif',
              width: 200, // Ajustez selon la taille souhaitée
              height: 200, // Ajustez selon la taille souhaitée
              frameRate: 25, // Ajustez selon les besoins
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
              _blocusText,
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
