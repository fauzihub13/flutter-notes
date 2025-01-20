import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_taptime/models/login_user_model.dart';
import 'package:flutter_taptime/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInAnonymous() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;
      return _userModel(user);
    } catch (e) {
      return UserModel(code: e.toString(), uid: null);
    }
  }

  Future signInEmailPassword(LoginUserModel loginUserModel) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: loginUserModel.email!, password: loginUserModel.password!);
      User? user = userCredential.user;
      return _userModel(user);
    } on FirebaseAuthException catch (e) {
      return UserModel(code: e.code, uid: null);
    }
  }

  Future registerEmailPassword(LoginUserModel loginUserModel) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: loginUserModel.email!, password: loginUserModel.password!);
      User? user = userCredential.user;
      return _userModel(user);
    } on FirebaseAuthException catch (e) {
      return UserModel(code: e.code, uid: null);
    } catch (e) {
      return UserModel(code: e.toString(), uid: null);
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return null;
    }
  }

  UserModel? _userModel(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userModel);
  }
}
