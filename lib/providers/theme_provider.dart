import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _textSize = 16;
  String _customTheme = 'system';
  bool _isRightToLeft = false;
  bool _isVerticalScroll = false;

  ThemeMode get themeMode => _themeMode;
  double get textSize => _textSize;
  String get customTheme => _customTheme;
  bool get isRightToLeft => _isRightToLeft;
  bool get isVerticalScroll => _isVerticalScroll;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setTextSize(double size) {
    _textSize = size;
    notifyListeners();
  }

  void setCustomTheme(String theme) {
    _customTheme = theme;
    if (theme == 'oled' || theme == 'blue_dark' || theme == 'green' || theme == 'purple') {
      setThemeMode(ThemeMode.dark);
    } else if (theme == 'sepia') {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.system);
    }
    notifyListeners();
  }

  void setRightToLeft(bool value) {
    _isRightToLeft = value;
    notifyListeners();
  }

  void setVerticalScroll(bool value) {
    _isVerticalScroll = value;
    notifyListeners();
  }
} 