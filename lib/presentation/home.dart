import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_study/model/StudyObject.dart';
import 'package:flutter_study/presentation/login.dart';
import 'package:flutter_study/widget/StudyObjectWidget.dart';

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseDatabase database = FirebaseDatabase.instance;
final FlutterSecureStorage storage = new FlutterSecureStorage();

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  static const String routeName = '/home';

  @override
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<Home> {
  String name = '';
  String email = '';
  String photoUrl = 'https://placeholdit.co//i/96x96?text=FS&bg=1d7ff4';
  DatabaseReference userReference;
  List<StudyObject> list = <StudyObject>[];
  Widget widgetList = new Text('Aguarde...');

  @override
  void initState() {
    auth.currentUser().then((FirebaseUser user) {
      setState(() {
        name = user.displayName;
        email = user.email;
        photoUrl = user.photoUrl;
      });

      userReference = database.reference().child('lists').child(user.uid);

      setState(
            () =>
        widgetList = new FirebaseAnimatedList(
          query: userReference.orderByChild('name'),
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) =>
          new StudyObjectWidget(
            studyObject:
            new StudyObject.fromJson(snapshot.key, snapshot.value),
            onUpdate: (StudyObject localStudyObject) =>
                _showInputDialog(localStudyObject),
            onDelete: (StudyObject localStudyObject) =>
                _delete(localStudyObject),
          ),
        ),
      );
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
      drawer: _buildDrawer(context),
      floatingActionButton: new FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showInputDialog(null),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return new Drawer(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text(name),
            accountEmail: new Text(email),
            currentAccountPicture: new CircleAvatar(
              backgroundImage: new NetworkImage(photoUrl),
            ),
          ),
          new ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Desconectar'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return new Column(
      children: <Widget>[
        new Flexible(
          child: widgetList,
        ),
      ],
    );
  }

  void _logout() async {
    await auth.signOut();
    await storage.delete(key: 'login_method');
    Navigator.of(context).pushReplacementNamed(Login.routeName);
  }

  Future<Null> _showInputDialog(StudyObject studyObject) async {
    final TextEditingController _nameCtl = new TextEditingController();
    final TextEditingController _descriptionCtl = new TextEditingController();

    if (studyObject == null) {
      studyObject = new StudyObject(null);
    }

    _nameCtl.text = studyObject.name;
    _descriptionCtl.text = studyObject.description;

    showDialog(
      context: context,
      barrierDismissible: false,
      child: new Dialog(
        child: new Padding(
          padding: const EdgeInsets.all(12.0),
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                ),
                child: const Text('Dados para inclusão:'),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: new TextField(
                  controller: _nameCtl,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(hintText: 'Nome'),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: new TextField(
                  controller: _descriptionCtl,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(hintText: 'Descrição'),
                ),
              ),
              new Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new RaisedButton(
                      onPressed: () {
                        _nameCtl.clear();
                        _descriptionCtl.clear();
                        Navigator.of(context).pop();
                      },
                      child: const Text('CANCELAR'),
                    ),
                    new RaisedButton(
                      onPressed: () {
                        studyObject.name = _nameCtl.text;
                        studyObject.description = _descriptionCtl.text;
                        _nameCtl.clear();
                        _descriptionCtl.clear();
                        _insertOrUpdate(studyObject);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Null> _insertOrUpdate(StudyObject studyObject) async {
    DatabaseReference localReference;

    if (studyObject.key == null) {
      localReference = userReference.push();
    } else {
      localReference = userReference.child(studyObject.key);
    }

    final TransactionResult transactionResult =
    await localReference.runTransaction((MutableData mutableData) async {
      mutableData.value = {
        'name': studyObject.name,
        'description': studyObject.description,
      };
      return mutableData;
    });

    if (transactionResult.committed) {
      Navigator.of(context).pop();
    } else {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }

  Future<Null> _delete(StudyObject studyObject) async {
    final TransactionResult transactionResult = await userReference
        .child(studyObject.key)
        .runTransaction((MutableData mutableData) async {
      mutableData.value = null;
      return mutableData;
    });

    if (!transactionResult.committed) {
      print('Transaction not committed.');
      if (transactionResult.error != null) {
        print(transactionResult.error.message);
      }
    }
  }
}
