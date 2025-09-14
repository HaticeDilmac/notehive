import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 255, 234, 138),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      primaryColor: const Color.fromARGB(255, 255, 234, 138),
      cardColor: Colors.grey[100],
      canvasColor: Colors.black,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF6750A4),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 255, 234, 138),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.black,
      primaryColor: const Color.fromARGB(255, 255, 234, 138),
      cardColor: Colors.grey[850],
      canvasColor: Colors.white, 
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white70,
        displayColor: Colors.white70,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Color(0xFF6750A4),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
