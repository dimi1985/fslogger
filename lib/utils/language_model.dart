import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageModel extends ChangeNotifier {
  Locale _locale;

  LanguageModel({required Locale initialLocale}) : _locale = initialLocale;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    notifyListeners();
    savePreferences(locale);
  }

  Future<void> savePreferences(Locale locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }
}

class L10n {
  static final all = [
    const Locale('en'), // English
    const Locale('el'), // Greek
  ];
}
