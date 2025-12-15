import 'package:flutter/material.dart';
import 'app_theme.dart';

class UIConstants {
  static const BorderRadius cardRadius =
      BorderRadius.all(Radius.circular(12));

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static EdgeInsets screenPadding =
      const EdgeInsets.symmetric(horizontal: 16);

  static TextStyle sectionTitle = const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static Color divider = Colors.grey.shade200;
}
