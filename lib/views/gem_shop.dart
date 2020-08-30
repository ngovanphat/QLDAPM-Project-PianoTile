import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/model/widget.dart';
import 'package:piano_tile/views/game_play.dart';
import 'package:piano_tile/views/game_play_online.dart';
import 'package:piano_tile/views/logged_in_profile.dart';
import 'package:piano_tile/views/profile.dart';
import 'package:piano_tile/views/music_list.dart';
import 'package:piano_tile/views/create_room.dart';
import 'package:piano_tile/model/room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piano_tile/helper/sharedPreferencesDefinition.dart';
import 'package:piano_tile/main.dart';
import 'package:firebase_database/firebase_database.dart';

class GemShop extends StatefulWidget {
  @override
  GemShopState createState() => GemShopState();
}

class GemShopState extends State<GemShop> {
  List<Widget> listCard = <Widget>[];
  Future<String> taskMakeCard;

  @override
  void initState() {
    super.initState();

    taskMakeCard = getGemPackInfo();
  }

  Future<String> getGemPackInfo() async {
    DataSnapshot data = await FirebaseDatabase.instance
        .reference()
        .child('gemDefinition/pack')
        .once();
    Map<dynamic, dynamic> packs = data.value;

    packs.forEach((key, value) {
      listCard.add(createCard(key, value));
    });

    return 'done';
  }

  Card createCard(key, value) {
    String packName = key;
    Map<dynamic, dynamic> content = value;
    String title = "${content['gemReward']} gems";
    String price = content['cashRequired'];

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Image.asset('assets/images/gems.png'),
            title: Text(title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                )),
            subtitle: Text(packName),
          ),
          ButtonBar(
            children: <Widget>[
              FlatButton(
                child: Text('BUY with ${price}'),
                onPressed: () {/* ... */},
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
//    return Center(
//      child: Card(
//        child: Column(
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            const ListTile(
//              leading: Icon(Icons.album),
//              title: Text('The Enchanted Nightingale'),
//              subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
//            ),
//            ButtonBar(
//              children: <Widget>[
//                FlatButton(
//                  child: const Text('BUY TICKETS'),
//                  onPressed: () {/* ... */},
//                ),
//              ],
//            ),
//          ],
//        ),
//      ),
//    );

    return Scaffold(
      backgroundColor: const Color(0xff004466),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
            Column(
              children: <Widget>[
                Row(children: <Widget>[
                  Image.asset(
                    'assets/images/basket.png',
                    width: 70,
                    height: 70,
                  ),
                  Text('Gem Shop',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 48,
                          color: Colors.white)),
                ]),
                FutureBuilder<String>(
                    future: taskMakeCard,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.hasData && snapshot.data == 'done') {
                        return Column(
                          children: listCard,
                        );
                      } else {
                        return Center(
                          child: Text('The Enchanted Nightingale'),
                        );
                      }
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
