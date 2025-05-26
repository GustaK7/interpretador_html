import 'package:flutter/material.dart';
import '../interface/interface.dart';

void main() {
  runApp(const InterpretadorApp());
}

class InterpretadorApp extends StatelessWidget {
  const InterpretadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interpretador BR',
      theme: ThemeData.dark(),
      home: const InterpretadorHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}



