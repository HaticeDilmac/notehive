import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(const Locale('tr')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isTr = prefs.getBool('isTurkish') ?? true;
    emit(Locale(isTr ? 'tr' : 'en'));
  }

  Future<void> toggleLanguage(bool isTurkish) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTurkish', isTurkish);
    emit(Locale(isTurkish ? 'tr' : 'en'));
  }
}
