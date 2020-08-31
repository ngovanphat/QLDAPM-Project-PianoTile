import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  if (type == sharedPrefValues.USER) {
    // get info from firebase database
    String userId = prefs.getString(sharedPrefKeys.getIdKey());
    DataSnapshot user = await FirebaseDatabase.instance
        .reference()
        .child('account/$userId')
        .once();

    if (user == null) {
      type = sharedPrefValues.GUEST;
      print('[main] get_user_from_firebase: failed, changed type to guest');
    } else {
      print('[main] user: $user');
      Map<dynamic, dynamic> rows = user.value;
      // get exp, gems
      exp = rows['exp'];
      gem = rows['gem'];
    }
  }

  if (type == sharedPrefValues.GUEST) {
    // type == GUEST

    // in-case first time install app
    // user will receive gems and exp of level 1
    // so get info of level 1 from firebase
    DataSnapshot data = await FirebaseDatabase.instance
        .reference()
        .child('levelDefinition')
        .once();
    List<dynamic> levels = data.value;

    // get info from local preferences
    exp = prefs.getInt(sharedPrefKeys.getExpKey()) ?? levels[0]['expRequired'];
    gem = prefs.getInt(sharedPrefKeys.getGemKey()) ?? levels[0]['gemReward'];
    print('[main] local exp: $exp, gem: $gem');
  }

  // resolve level and get next-exp value
  int levelValue = 1;
  int nextExpValue = 0;
  DataSnapshot data = await FirebaseDatabase.instance
      .reference()
      .child('levelDefinition')
      .once();
  List<dynamic> levels = data.value;
  print('[main] levels: $levels');
  for (int i = 0; i < levels.length; i++) {
    Map<dynamic, dynamic> level = levels[i];
    if (level['expRequired'] > exp) {
      levelValue = level['level'] - 1;
      nextExpValue = level['expRequired'];
      break;
    }
  }
  print('[main] level: $levelValue, next exp: $nextExpValue');

  // save exp, gem
  prefs.setInt(sharedPrefKeys.userType, type);
  prefs.setInt(sharedPrefKeys.getExpKey(), exp);
  prefs.setInt(sharedPrefKeys.getGemKey(), gem);
  prefs.setInt(sharedPrefKeys.getLevelKey(), levelValue);
  prefs.setInt(sharedPrefKeys.getNextExpKey(), nextExpValue);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

// Register the RouteObserver as a navigation observer.
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

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
      navigatorObservers: [routeObserver],
    );
  }
}
