// lib/screens/jamhood/jamhood_theme.dart
import 'package:flutter/material.dart';

class JamHoodTheme {
  static const Color darkBg = Color(0xFF1B0938);
  static const Color cardBg = Color(0xFF2C1654);
  static const Color accentPurple = Color(0xFF46178F);

  // 4 Iconic Answer Options
  static const Color red = Color(0xFFE21B3C);     // Triangle ▲
  static const Color blue = Color(0xFF1368CE);    // Diamond ◆
  static const Color yellow = Color(0xFFD89E00);  // Circle ●
  static const Color green = Color(0xFF26890C);   // Square ■

  static const List<Color> optionColors = [red, blue, yellow, green];
  static const List<IconData> optionIcons = [
    Icons.change_history, // Triangle
    Icons.crop_square_sharp, // Diamond (rotated) or square
    Icons.circle_outlined,
    Icons.square,
  ];

  static const List<String> optionShapes = ['▲', '◆', '●', '■'];

  static BoxDecoration gradientBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF1B0938), Color(0xFF33146B), Color(0xFF100524)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
