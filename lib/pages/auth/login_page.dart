import 'package:flutter/material.dart';
import 'package:flutter_taptime/models/login_user_model.dart';
import 'package:flutter_taptime/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  final Function? toggleView;
  const LoginPage({super.key, this.toggleView});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showHide = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Login Page',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Email'),
                    ),
                    _emailField(),
                    const SizedBox(
                      height: 20,
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Password'),
                    ),
                    _passwordField(),
                    const SizedBox(
                      height: 20,
                    ),
                    _registerButton(),
                    const SizedBox(
                      height: 20,
                    ),
                    _loginAnonymous(),
                    const SizedBox(
                      height: 20,
                    ),
                    __loginEmailPassword(),
                    const SizedBox(
                      height: 20,
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: emailController,
      autofocus: false,
      validator: (value) {
        if (value!.isEmpty) {
          return "Email tidak boleh kosong";
        } else if (value.contains('@') && value.endsWith('.com')) {
          return null;
        } else {
          return "Email tidak sesuai";
        }
      },
    );
  }

  Widget _passwordField() {
    return TextFormField(
      obscureText: _showHide,
      controller: passwordController,
      autofocus: false,
      validator: (value) {
        if (value!.isEmpty) {
          return "Password tidak boleh kosong";
        } else {
          return null;
        }
      },
    );
  }

  Widget _registerButton() {
    return TextButton(
        onPressed: () {
          widget.toggleView!();
        },
        child: const Text('Belum punya akun? Daftar disini.'));
  }

  Widget _loginAnonymous() {
    return ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            dynamic result = await _authService.signInAnonymous();
            if (result.uid == null) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(result.code),
                    );
                  });
            }
          }
        },
        child: const Text('Login Anonymous'));
  }

  Widget __loginEmailPassword() {
    return ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            dynamic result = await _authService.signInEmailPassword(
                LoginUserModel(
                    email: emailController.text,
                    password: passwordController.text));
            if (result.uid == null) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(result.code),
                    );
                  });
            }
          }
        },
        child: const Text('Login Email'));
  }
}
