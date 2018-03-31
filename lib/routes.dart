import 'package:flutter/material.dart';
import 'package:flutter_study/home.dart';
import 'package:flutter_study/login.dart';

class Routes {
  static Map<String, WidgetBuilder> build(BuildContext context) {
    return <String, WidgetBuilder>{
      Login.routeName: (BuildContext context) => new Login(),
      Home.routeName: (BuildContext context) => new Home(),
    };
  }
}
