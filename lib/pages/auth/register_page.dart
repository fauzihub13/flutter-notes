import 'package:flutter/material.dart';
import 'package:flutter_taptime/models/login_user_model.dart';
import 'package:flutter_taptime/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  final Function? toggleView;
  const RegisterPage({super.key, this.toggleView});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _showHide = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register Page',
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
                    _emailField(),
                    const SizedBox(
                      height: 20,
                    ),
                    _passwordField(),
                    const SizedBox(
                      height: 20,
                    ),
                    _registerButton(),
                    const SizedBox(
                      height: 20,
                    ),
                    _registerNewUser(),
                    const SizedBox(
                      height: 20,
                    ),
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
      decoration: const InputDecoration(
          hintText: 'Masukkan email', label: Text('Email')),
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
      decoration: InputDecoration(
          hintText: 'Masukkan password',
          label: const Text('Password'),
          suffixIcon: GestureDetector(
            child: const Icon(Icons.visibility),
            onTap: () {
              setState(() {
                _showHide = !_showHide;
              });
            },
          )),
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
        child: const Text('Sudah punya akun? Masuk disini.'));
  }

  Widget _registerNewUser() {
    return ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            dynamic result = await _authService.registerEmailPassword(
                LoginUserModel(
                    email: emailController.text,
                    password: passwordController.text));
            if (result.uid == null) {
              if (!mounted) return;

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
        child: const Text('Register'));
  }
}
