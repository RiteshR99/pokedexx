import 'package:flutter/material.dart';
import 'splash_screen.dart';

void main() {
  runApp(const pokedex());}

class pokedex extends StatelessWidget {
  const pokedex({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

