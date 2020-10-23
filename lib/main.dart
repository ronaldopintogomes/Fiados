import 'package:fiados/visao/Contas.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiados',
      theme: ThemeData(
        primaryColor: Colors.deepOrange[600],
      ),
      home: Contas(),
    );
  }
}
