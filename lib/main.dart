import 'package:flutter/material.dart';
import 'package:flutter_study/presentation/login.dart';
import 'package:flutter_study/routes.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: new Login(),
      routes: Routes.build(context),
    );
  }
}
