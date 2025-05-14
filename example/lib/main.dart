import 'package:flutter/material.dart';

import 'presenter/presenter.dart';

void main() {
  runApp(const MainApp());
}

class ExamplePresenter extends Presenter {}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final ExamplePresenter examplePresenter = ExamplePresenter();

  @override
  void dispose() {
    examplePresenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('Hello World!'))),
    );
  }
}
