import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadTimeWidget(),
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
        child: Column(
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
          ],
        ),
      ),
    );
  }
}