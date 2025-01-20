import 'package:flutter/material.dart';
import 'package:flutter_taptime/pages/auth/login_page.dart';
import 'package:flutter_taptime/pages/auth/register_page.dart';

class Handler extends StatefulWidget {
  const Handler({super.key});

  @override
  State<Handler> createState() => _HandlerState();
}

class _HandlerState extends State<Handler> {
  bool showSignIn = true;

  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return LoginPage(
        toggleView: toggleView,
      );
    } else {
      return const RegisterPage();
    }
  }
}
