import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Google Sign-In Demo for Web',
      home: SignInDemo(),
    );
  }
}

class SignInDemo extends StatefulWidget {
  @override
  _SignInDemoState createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1018677712606-ijnh5490kescaakkrko29aflf800a61h.apps.googleusercontent.com',
  );

  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
  }

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Sign-In Demo for Web'),
      ),
      body: Center(
        child: user != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Signed in as ${user.displayName} (${user.email})'),
                  ElevatedButton(
                    child: Text('Sign Out'),
                    onPressed: _handleSignOut,
                  ),
                ],
              )
            : ElevatedButton(
                child: Text('Sign In with Google'),
                onPressed: _handleSignIn,
              ),
      ),
    );
  }
}
