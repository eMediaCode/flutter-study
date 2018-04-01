import 'dart:async';
import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_study/model/StudyObject.dart';
import 'package:flutter_study/presentation/login.dart';
import 'package:flutter_study/widget/StudyObjectWidget.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseDatabase _database = FirebaseDatabase.instance;
final FlutterSecureStorage _storage = new FlutterSecureStorage();

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
  DatabaseReference _userReference;
  List<StudyObject> _list = <StudyObject>[];

  StreamSubscription _streamSubscription;

  @override
  void initState() {
    _auth.currentUser().then((FirebaseUser user) {
      setState(() {
        name = user.displayName;
        email = user.email;
        photoUrl = user.photoUrl;
      });

      _userReference = _database.reference().child('lists').child(user.uid);

      _getStreamSubscription().then((StreamSubscription streamSubscription) =>
      _streamSubscription = streamSubscription);
    });

    super.initState();
  }

  @override
  void dispose() {
    if (_streamSubscription != null) {
      _streamSubscription.cancel();
    }
    super.dispose();
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
    return new ListView(
      children: _list
          .map((StudyObject studyObject) =>
      new StudyObjectWidget(
        studyObject,
            () => _delete(studyObject), // TODO - Como faz isso direito?
            () => _showInputDialog(studyObject),
      ))
          .toList(),
    );
  }

  void _logout() async {
    await _auth.signOut();
    await _storage.delete(key: 'login_method');
    Navigator.of(context).pushReplacementNamed(Login.routeName);
  }

  Future<StreamSubscription<Event>> _getStreamSubscription() async {
    return _userReference.onValue.listen((Event event) {
      _list.clear();
      if (event.snapshot.value != null) {
        new SplayTreeMap.from(event.snapshot.value).forEach((key, value) {
          StudyObject studyObject = new StudyObject.fromJson(key, value);
          setState(() => _list.add(studyObject));
        });
      }
    });
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
                        _setData(studyObject);
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

  Future<Null> _setData(StudyObject studyObject) async {
    TransactionResult transactionResult;

    // TODO - Melhorar essa implementação.

    if (studyObject.key == null) {
      transactionResult = await _userReference
          .push()
          .runTransaction((MutableData mutableData) async {
        mutableData.value = {
          'name': studyObject.name,
          'description': studyObject.description,
        };
        return mutableData;
      });
    } else {
      transactionResult = await _userReference
          .child(studyObject.key)
          .runTransaction((MutableData mutableData) async {
        mutableData.value = {
          'name': studyObject.name,
          'description': studyObject.description,
        };
        return mutableData;
      });
    }

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
    final TransactionResult transactionResult = await _userReference
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
