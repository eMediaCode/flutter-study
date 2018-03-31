import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_study/presentation/login.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
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

  @override
  void initState() {
    _auth.currentUser().then((FirebaseUser user) {
      print(user);
      setState(() {
        name = user.displayName;
        email = user.email;
        photoUrl = user.photoUrl;
      });
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
    );
  }

  Widget _buildBody(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Center(
          child: const Text('Home'),
        ),
      ],
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
//            decoration: new BoxDecoration(
//              color: Colors.black26,
//              image: new DecorationImage(
//                image: new NetworkImage(
//                  'https://placeimg.com/500/300/any',
//                ),
//              ),
//            ),
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

  void _logout() async {
    await _auth.signOut();
    await _storage.delete(key: 'login_method');
    Navigator.of(context).pushReplacementNamed(Login.routeName);
  }
}
