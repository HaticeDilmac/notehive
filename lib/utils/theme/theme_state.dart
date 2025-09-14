import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeState {
  final ThemeMode mode;
  final ThemeData theme;

  const ThemeState({required this.mode, required this.theme});

  /// Light tema için hazır state
  factory ThemeState.light() {
    return ThemeState(mode: ThemeMode.light, theme: AppTheme.light());
  }

  /// Dark tema için hazır state
  factory ThemeState.dark() {
    return ThemeState(mode: ThemeMode.dark, theme: AppTheme.dark());
  }

  ThemeState copyWith({ThemeMode? mode, ThemeData? theme}) {
    return ThemeState(mode: mode ?? this.mode, theme: theme ?? this.theme);
  }
}
