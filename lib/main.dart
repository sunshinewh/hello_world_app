import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthState(prefs),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<AuthState>(
        builder: (context, authState, _) {
          if (authState.status == AuthStatus.initial) {
            return SplashScreen();
          } else {
            return LoadTimeWidget();
          }
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading...'),
          ],
        ),
      ),
    );
  }
}

class LoadTimeWidget extends StatefulWidget {
  @override
  _LoadTimeWidgetState createState() => _LoadTimeWidgetState();
}

class _LoadTimeWidgetState extends State<LoadTimeWidget> {
  late Stopwatch _stopwatch;
  String _loadTime = "Calculating...";

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateLoadTime());
  }

  void _calculateLoadTime() {
    _stopwatch.stop();
    setState(() {
      _loadTime = "${(_stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)} seconds";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello World App'),
      ),
      body: Center(
        child: Consumer<AuthState>(
          builder: (context, authState, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hello, World!',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 20),
                Text(
                  'Load Time: $_loadTime',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                if (authState.user != null)
                  Text('Signed in as: ${authState.user!.email}')
                else
                  ElevatedButton(
                    onPressed: () async {
                      await authState.signIn();
                      if (authState.error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authState.error!)),
                        );
                      }
                    },
                    child: Text('Sign in with Google'),
                  ),
                if (authState.user != null)
                  ElevatedButton(
                    onPressed: () async {
                      await authState.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Signed out successfully.')),
                      );
                    },
                    child: Text('Sign out'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}