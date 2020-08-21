import 'package:flutter/material.dart';
import 'package:piano_tile/views/home.dart';
import 'package:piano_tile/views/game_play.dart';
import 'package:piano_tile/views/game_play_online.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piano Tiles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: Colors.blue),
//      home: Home(),

      initialRoute: '/home',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/home': (context) => Home(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/gameplay': (context) => GamePlay(),
        '/gameplayonline': (context) => GamePlayOnline(),
      },
    );
  }
}
