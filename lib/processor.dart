import 'package:flutter/material.dart';
import 'input.dart';

class MainWindow extends StatefulWidget {
  @override
  State createState() => InputState();
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainWindow());
  }
}
