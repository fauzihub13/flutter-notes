import 'package:flutter/material.dart';
import 'package:flutter_taptime/models/user_model.dart';
import 'package:flutter_taptime/pages/home/home_page.dart';
import 'package:flutter_taptime/pages/home/todo_list_page.dart';

class LandingPage extends StatefulWidget {
  final UserModel? userModel;
  const LandingPage({super.key, this.userModel});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _selectedIndex = 0;
  final menuItems = [
    const BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'To Do'),
    const BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notes'),
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      TodoListPage(
        userModel: widget.userModel,
      ),
      HomePage(
        userModel: widget.userModel,
      ),
    ];
  }

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
