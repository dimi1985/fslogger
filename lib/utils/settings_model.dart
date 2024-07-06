import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  bool _darkTheme = false;
  String _language = 'English';
  bool _defaultDynamicMode = true;

  bool get darkTheme => _darkTheme;
  String get language => _language;
  bool get defaultDynamicMode => _defaultDynamicMode;

   int _syncPreference = 0; // 0 = Auto, 1 = Manual, 2 = Periodic
    int get syncPreference => _syncPreference;

  SettingsModel() {
    loadPreferences();
  }

  void toggleTheme(bool value) {
    _darkTheme = value;
    notifyListeners();
    savePreferences();
  }

  void changeLanguage(String newLanguage) {
    _language = newLanguage;
    notifyListeners();
    savePreferences();
  }

  void toggleFlightMode(bool value) {
    _defaultDynamicMode = value;
    notifyListeners();
    savePreferences();
  }

  Future<void> loadPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _darkTheme = prefs.getBool('darkTheme') ?? false;
    _language = prefs.getString('language') ?? 'English';
    _defaultDynamicMode = prefs.getBool('defaultDynamicMode') ?? true;
    _syncPreference = prefs.getInt('syncPreference') ?? 0;
    notifyListeners();
  }

  Future<void> savePreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkTheme', _darkTheme);
    await prefs.setString('language', _language);
    await prefs.setBool('defaultDynamicMode', _defaultDynamicMode);
  }

  Future<void> saveSyncPreference(int preference) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('syncPreference', preference);
    _syncPreference = preference;
    notifyListeners();
  }
}
