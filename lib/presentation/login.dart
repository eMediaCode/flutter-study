import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_study/model/LoginMethod.dart';
import 'package:flutter_study/presentation/home.dart';
import 'package:flutter_study/util/MyDialogs.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();
final FlutterSecureStorage _storage = new FlutterSecureStorage();

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  static const String routeName = '/login';

  @override
  _LoginState createState() => new _LoginState();
}

class _LoginState extends State<Login> {
  @override
  void initState() {
    _storage.read(key: 'login_method').then((value) {
      if (value != null) {
        switch (value) {
          case LoginMethod.GOOGLE:
            _handlerGoogleLogin();
            break;
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Firebase Study'),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(
            top: 40.0,
          ),
          child: new Image.asset(
            'assets/firebase_icon.png',
            height: 150.0,
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(),
          child: const Text(
            'Selecione uma forma para entrar:',
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(
            bottom: 80.0,
          ),
          child: new Center(
            child: new FlatButton(
              child: new Image.asset(
                  'assets/btn_google_signin_light_normal_web.png'),
              onPressed: _handlerGoogleLogin,
            ),
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(
            bottom: 40.0,
          ),
          child: new Text('Por enquanto é só uma forma de autenticação.'),
        )
      ],
    );
  }

  Future<FirebaseUser> _googleLogin() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    FirebaseUser user = await _auth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return user;
  }

  void _handlerGoogleLogin() {
    MyDialogs.circularWating(context, 'Autenticando...');
    _googleLogin().then((FirebaseUser user) {
      _storage.write(key: 'login_method', value: LoginMethod.GOOGLE);
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed(Home.routeName);
    }).catchError((e) => print(e));
  }
}
