import 'package:flutter/material.dart';

import 'package:piano_tile/views/home.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget  {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piano Tiles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: Colors.blue
      ),
      home: Home(),
    );
  }
}
