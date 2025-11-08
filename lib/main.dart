import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/book_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/books_list_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: ScanToBookApp(),
    ),
  );
}

class ScanToBookApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final ThemeData oledDarkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: ColorScheme.dark(
        background: Colors.black,
        surface: Colors.grey[900]!,
        primary: Colors.white,
        secondary: Colors.blueGrey,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      textTheme: Theme.of(context).textTheme.apply(
        fontSizeFactor: themeProvider.textSize / 16,
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      useMaterial3: true,
    );
    final ThemeData modernLightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      colorScheme: ColorScheme.light(
        background: Colors.white,
        surface: Colors.grey[100]!,
        primary: Colors.black,
        secondary: Colors.blueGrey,
        onSurface: Colors.black87,
        onBackground: Colors.black87,
      ),
      textTheme: Theme.of(context).textTheme.apply(
        fontSizeFactor: themeProvider.textSize / 16,
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.black54),
        hintStyle: TextStyle(color: Colors.black38),
      ),
      useMaterial3: true,
    );
    final ThemeData blueDarkTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF192D73),
      colorScheme: ColorScheme.dark(
        background: Color(0xFF192D73),
        surface: Color(0xFF1A3A8A),
        primary: Colors.white,
        secondary: Colors.blueGrey,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      textTheme: Theme.of(context).textTheme.apply(
        fontSizeFactor: themeProvider.textSize / 16,
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      useMaterial3: true,
    );
    final ThemeData sepiaTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: Color(0xFFF4E4BC),
      colorScheme: ColorScheme.light(
        background: Color(0xFFF4E4BC),
        surface: Color(0xFFE8D5A3),
        primary: Color(0xFF5C4A37),
        secondary: Color(0xFF8B7355),
        onSurface: Color(0xFF3E2F1F),
        onBackground: Color(0xFF3E2F1F),
      ),
      textTheme: Theme.of(context).textTheme.apply(
        fontSizeFactor: themeProvider.textSize / 16,
        bodyColor: Color(0xFF3E2F1F),
        displayColor: Color(0xFF3E2F1F),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Color(0xFF5C4A37)),
        hintStyle: TextStyle(color: Color(0xFF8B7355)),
      ),
      useMaterial3: true,
    );
    final ThemeData greenTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF1A3A2E),
      colorScheme: ColorScheme.dark(
        background: Color(0xFF1A3A2E),
        surface: Color(0xFF2D5A47),
        primary: Colors.white,
        secondary: Color(0xFF4A9B7A),
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      textTheme: Theme.of(context).textTheme.apply(
        fontSizeFactor: themeProvider.textSize / 16,
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      useMaterial3: true,
    );
    final ThemeData purpleTheme = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF2D1B3D),
      colorScheme: ColorScheme.dark(
        background: Color(0xFF2D1B3D),
        surface: Color(0xFF3D2B4D),
        primary: Colors.white,
        secondary: Color(0xFF9B7BB8),
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      textTheme: Theme.of(context).textTheme.apply(
        fontSizeFactor: themeProvider.textSize / 16,
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.white70),
        hintStyle: TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white38)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      ),
      useMaterial3: true,
    );
    ThemeData getDarkTheme() {
      switch (themeProvider.customTheme) {
        case 'blue_dark':
          return blueDarkTheme;
        case 'green':
          return greenTheme;
        case 'purple':
          return purpleTheme;
        case 'sepia':
          return sepiaTheme;
        default:
          return oledDarkTheme;
      }
    }
    return MaterialApp(
      title: 'ScanToBook',
      theme: themeProvider.customTheme == 'sepia' ? sepiaTheme : modernLightTheme,
      darkTheme: getDarkTheme(),
      themeMode: themeProvider.customTheme == 'sepia' 
          ? ThemeMode.light
          : (themeProvider.customTheme == 'system' ? themeProvider.themeMode : ThemeMode.dark),
      home: BooksListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
