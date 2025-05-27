import 'package:flutter/material.dart';
import '../interface/interface.dart';

void main() {
  runApp(const InterpretadorApp());
}

class InterpretadorApp extends StatefulWidget {
  const InterpretadorApp({super.key});

  @override
  State<InterpretadorApp> createState() => _InterpretadorAppState();
}

class _InterpretadorAppState extends State<InterpretadorApp> {
  bool _isDark = true;

  @override
  Widget build(BuildContext context) {
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      primaryColor: Colors.blueGrey[50],
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF8F6FA),
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      cardColor: Colors.white,
      canvasColor: Colors.white,
      dialogBackgroundColor: Colors.white,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Colors.black87, fontFamily: 'Fira Mono'),
        bodyLarge: TextStyle(color: Colors.black87, fontFamily: 'Fira Mono'),
        titleLarge: TextStyle(color: Colors.black87, fontFamily: 'Fira Mono'),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      dividerColor: Colors.grey[300],
      hintColor: Colors.grey,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[50],
        border: const OutlineInputBorder(),
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[200],
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.blueGrey,
        selectionColor: Color(0xFFB3E5FC),
        selectionHandleColor: Colors.blueGrey,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    return MaterialApp(
      title: 'Interpretador BR',
      theme: _isDark ? ThemeData.dark() : lightTheme,
      home: InterpretadorHome(
        isDark: _isDark,
        onToggleTheme: () {
          setState(() {
            _isDark = !_isDark;
          });
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}



