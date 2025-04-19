import 'package:e_book_reader/splash_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(EBookApp());

class EBookApp extends StatelessWidget {
  const EBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter eBook App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashPage(),
    );
  }
}
