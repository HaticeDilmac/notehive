import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const _key = "theme_mode";

  ThemeCubit() : super(ThemeState.light()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    //loadiing theme functiion
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);

    switch (value) {
      case "light":
        emit(ThemeState.light());
        break;
      case "dark":
        emit(ThemeState.dark());
        break;
      default:
        emit(ThemeState.light()); // default light
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        emit(ThemeState.light());
        await prefs.setString(_key, "light");
        break;
      case ThemeMode.dark:
        emit(ThemeState.dark());
        await prefs.setString(_key, "dark");
        break;
      default:
        emit(ThemeState.light());
        await prefs.setString(_key, "light");
    }
  }
}
