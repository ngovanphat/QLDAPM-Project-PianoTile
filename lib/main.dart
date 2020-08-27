import 'package:flutter/material.dart';
import 'package:piano_tile/views/home.dart';
import 'package:piano_tile/views/game_play.dart';
import 'package:piano_tile/views/game_play_online.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piano_tile/helper/sharedPreferencesDefinition.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {

  // if change main to async
  // app needs this line to run properly
  WidgetsFlutterBinding.ensureInitialized();

  // check if guest or logged-in user
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int type = prefs.getInt(sharedPrefKeys.userType) ?? sharedPrefValues.GUEST;
  int exp = null;
  int gem = null;

  if(type == sharedPrefValues.USER){

    // get info from firebase database
    String userId = prefs.getString(sharedPrefKeys.userId);
    DataSnapshot user = await FirebaseDatabase.instance.reference()
        .child('account/$userId')
        .once();

    if(user == null) {
      type = sharedPrefValues.GUEST;
      print('[main] get_user_from_firebase: failed, changed type to guest');
    }
    else {
      print('[main] user: $user');
      Map<dynamic, dynamic> rows = user.value;
      // get exp, gems
      exp = rows['exp'];
      gem = rows['gem'];

      // save exp, gem
      prefs.setInt(sharedPrefKeys.userExp, exp);
      prefs.setInt(sharedPrefKeys.userGem, gem);
    }

  }

  if(type == sharedPrefValues.GUEST){
    // type == GUEST

    // get info from local preferences
    int exp = prefs.getInt(sharedPrefKeys.guestExp) ?? 0;
    int gem = prefs.getInt(sharedPrefKeys.guestGem) ?? 0;
    print('[main] local exp: $exp, gem: $gem');

    // save exp, gem
    prefs.setInt(sharedPrefKeys.guestExp, exp);
    prefs.setInt(sharedPrefKeys.guestGem, gem);
  }


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
 