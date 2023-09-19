// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'components/bottom_nav_bar.dart';
import 'pages/home.dart';
import './pages/history.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List pages = [
    MyHomePage(),
    History(),
  ];

  navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snacks',
      home: Scaffold(
        bottomNavigationBar: CustomBottomNavBar(
            onTabChange: (index) => navigateBottomBar(index)),
        body: pages[_selectedIndex],
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
