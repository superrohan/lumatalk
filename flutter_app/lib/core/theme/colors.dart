import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF5F3DC4);

  // Secondary colors
  static const Color secondary = Color(0xFF00B894);
  static const Color secondaryLight = Color(0xFF55EFC4);
  static const Color secondaryDark = Color(0xFF00875A);

  // Background
  static const Color background = Color(0xFFF8F9FA);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2D2D2D);

  // Text
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textDisabled = Color(0xFFB2BEC3);
  static const Color textDark = Color(0xFFDFE6E9);

  // Status colors
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFFF7675);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color info = Color(0xFF74B9FF);

  // Language-specific accent colors
  static const Color sourceLanguage = Color(0xFF6C5CE7);
  static const Color targetLanguage = Color(0xFF00B894);

  // Waveform colors
  static const Color waveformActive = Color(0xFF6C5CE7);
  static const Color waveformInactive = Color(0xFFDFE6E9);

  // Card colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2D2D2D);

  // Confidence heat colors
  static const Color confidenceHigh = Color(0xFF00B894);
  static const Color confidenceMedium = Color(0xFFFDCB6E);
  static const Color confidenceLow = Color(0xFFFF7675);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
