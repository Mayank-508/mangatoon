import 'package:flutter/material.dart';

import 'widgets/home_screen.dart'; // Corrected import for Home Screen

void main() {
  runApp(WebtoonExplorerApp());
}

class WebtoonExplorerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Webtoon Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}
