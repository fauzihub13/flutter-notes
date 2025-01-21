import 'package:flutter/material.dart';
import 'package:flutter_taptime/pages/home/home_page.dart';
import 'package:flutter_taptime/pages/home/todo_list_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;
  final menuItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'To Do'),
    const BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
  ];

  final List<Widget> _pages = [
    const TodoListPage(),
    const HomePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(0),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          items: menuItems,
          selectedItemColor: Colors.lightBlue,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
