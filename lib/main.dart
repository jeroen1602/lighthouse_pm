import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'pages/MainPage.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'Lighthouse PM',
        theme: ThemeData(
            primarySwatch: Colors.grey,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        home: MainPage());
  }
}
