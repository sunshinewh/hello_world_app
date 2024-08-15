import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS 
        ? '1018677712606-v8ams6qa3ue9vovrlhmbnmcj39lhu2r4.apps.googleusercontent.com'
        : null,
  );

  GoogleSignInAccount? _user;
  AuthStatus _status = AuthStatus.initial;
  String? _error;
  final SharedPreferences prefs;

  AuthState(this.prefs) {
    _checkSignInStatus();
  }

  GoogleSignInAccount? get user => _user;
  AuthStatus get status => _status;
  String? get error => _error;

  Future<void> _checkSignInStatus() async {
    final isSignedIn = prefs.getBool('isSignedIn') ?? false;
    if (isSignedIn) {
      try {
        _user = await _googleSignIn.signInSilently();
        _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      } catch (error) {
        _status = AuthStatus.unauthenticated;
        _error = 'Failed to sign in silently: $error';
      }
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> signIn() async {
    try {
      _status = AuthStatus.initial;
      _error = null;
      notifyListeners();

      _user = await _googleSignIn.signIn();
      if (_user != null) {
        await prefs.setBool('isSignedIn', true);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
        _error = 'Sign in cancelled by user';
      }
    } catch (error) {
      _status = AuthStatus.unauthenticated;
      _error = 'Error during sign in: $error';
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      await prefs.setBool('isSignedIn', false);
      _user = null;
      _status = AuthStatus.unauthenticated;
    } catch (error) {
      _error = 'Error signing out: $error';
    }
    notifyListeners();
  }
}