import 'package:flutter/material.dart';
import 'package:flutter_taptime/models/user_model.dart';
import 'package:flutter_taptime/pages/auth/handler.dart';
import 'package:flutter_taptime/pages/home/home_page.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget{
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);

    if(user == null){
      return Handler();
    } else{
      return HomePage();
    }
  }

}