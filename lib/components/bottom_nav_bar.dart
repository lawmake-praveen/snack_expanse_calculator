import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

// ignore: must_be_immutable
class CustomBottomNavBar extends StatefulWidget {
  void Function(int)? onTabChange;
  CustomBottomNavBar({super.key, required this.onTabChange});

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return GNav(
        backgroundColor: Colors.black,
        color: Colors.grey,
        activeColor: Colors.black,
        mainAxisAlignment: MainAxisAlignment.center,
        tabBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        onTabChange: (value) => widget.onTabChange!(value),
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Home',
            textSize: 35,
          ),
          GButton(
            icon: Icons.history,
            text: 'History',
            textSize: 35,
          )
        ]);
  }
}
