import 'package:flutter/material.dart';
import 'package:the_holy_quran/widgets/splash_screen.dart';

void main() => runApp(const theholyquran());

class theholyquran extends StatelessWidget {
  const theholyquran({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "The Holy Quran",
      home: SplashScreen(),
    );
  }
}
