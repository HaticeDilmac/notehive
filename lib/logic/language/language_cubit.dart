import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit() : super(Locale(_deviceDefaultLanguageCode())) {
    _load();
  }

  static String _deviceDefaultLanguageCode() {
    final code = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    return code.startsWith('tr') ? 'tr' : 'en';
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final isTr = prefs.getBool('isTurkish');
    if (isTr != null) {
      emit(Locale(isTr ? 'tr' : 'en'));
    }
  }

  Future<void> toggleLanguage(bool isTurkish) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTurkish', isTurkish);
    emit(Locale(isTurkish ? 'tr' : 'en'));
  }
}
