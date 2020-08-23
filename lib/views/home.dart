import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/model/widget.dart';
import 'package:piano_tile/views/game_play.dart';
import 'package:piano_tile/views/game_play_online.dart';
import 'package:piano_tile/views/profile.dart';
import 'package:piano_tile/views/music_list.dart';
import 'package:piano_tile/views/create_room.dart';
import 'package:piano_tile/model/ad_manager.dart';
import 'package:firebase_admob/firebase_admob.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  int _currentIndex = 0;

  Future<void> _initAdMob() {
    // TODO: Initialize AdMob SDK
    return FirebaseAdMob.instance.initialize(appId: AdManager.appId);
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat();
  }

  @override
  dispose() {
   _animationController.dispose(); // you need this
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff004466),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
                RowOnTop(context, 0, 0),
                Container(
                    margin: EdgeInsets.only(top: 100),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (_, child) {
                              return Transform.rotate(
                                angle: _animationController.value * 1 * 3.14,
                                child: child,
                              );
                            },
                            child: Image.asset('assets/images/disk.png'),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Text(
                              '1. BigCity Boi',
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            width: 350,

                            height: 55,

                            margin: EdgeInsets.only(top: 20),
                            child: FlatButton(
                              onPressed: () {

                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => GamePlay()));


                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(70),
                                  side: BorderSide(
                                      color: Colors.white, width: 3)),
                              child: Text(
                                'Play',
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                              color: Colors.white24,
                            ),
                          ),
                          Container(
                            width: 350,

                            height: 55,
                            margin: EdgeInsets.only(top: 20),


                            child: FlatButton(
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (_) => Material(
                                    type: MaterialType.transparency,
                                    // Aligns the container to center
                                    child: FractionallySizedBox(heightFactor: 1, widthFactor: 0.80,
                                        child: Center(
                                        child: new Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          new FlatButton(
                                              color: Colors.blueAccent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(70),
                                                  side: BorderSide(
                                                      color: Colors.white, width: 3)),
                                              child: new Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(Icons.add_circle_outline, color: Colors.white, size: 50),
                                                  Text(
                                                    "Create room",
                                                    style: TextStyle(color: Colors.white, fontSize: 25),
                                                  )
                                                ],
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(builder: (context) => CreateRoom()));
                                              }),
                                          Padding(padding: const EdgeInsets.only(top: 30)),
                                          new FlatButton(
                                              color: Colors.blueAccent,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(70),
                                                  side: BorderSide(
                                                      color: Colors.white, width: 3)),
                                              child: new Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  new Icon(Icons.people_outline, color: Colors.white, size: 50),
                                                  new Text(
                                                    "Join room",
                                                    style: TextStyle(color: Colors.white, fontSize: 25),
                                                  )
                                                ],
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                    context: context,
                                                    builder: (_) => Material(
                                                        type: MaterialType.transparency,
                                                    child: FractionallySizedBox(heightFactor: 0.25, widthFactor: 0.80,
                                                        child: Container(
                                                          padding: new EdgeInsets.all(25.0),
                                                        decoration: new BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                                                        child: Center(
                                                            child: new Column(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: <Widget>[
                                                                new TextField(
                                                                  decoration: new InputDecoration(hintText: "Enter room code"),
                                                                  style: TextStyle(fontSize: 25)
                                                                ),
                                                                Padding(padding: const EdgeInsets.only(top: 40)),
                                                                new FlatButton(
                                                                  color: Colors.blueAccent,
                                                                  minWidth: 200,
                                                                  height: 50,
                                                                  child: new Text("Join", style: TextStyle(fontSize: 25),),
                                                                  onPressed: (){
                                                                    print("Joined");
                                                                  },
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(70),
                                                                      side: BorderSide(
                                                                          color: Colors.white, width: 3)),
                                                                )
                                                              ],
                                                            )
                                                        )
                                                    )
                                                    )
                                                )
                                                );
                                              }),
                                        ]
                                      )
                                    )
                                    )
                                    )
                                );
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(70),
                                  side: BorderSide(
                                      color: Colors.white, width: 3)),
                              child: Text(
                                'Multiplay',
                                style: TextStyle(
                                    fontSize: 25, color: Colors.white),
                              ),
                              color: Colors.white24,
                            ),
                          )
                        ]))
              ],
            ),
          ),
          MusicList(),
          Profile(),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: allDestinations.map((Destination destination) {
          return BottomNavigationBarItem(
              icon: Icon(destination.icon), title: Text(destination.title));
        }).toList(),
        iconSize: 32,
        selectedItemColor: Colors.white,
        backgroundColor: const Color(0xff004466),
      ),
    );
  }
}

class Destination {
  const Destination(this.title, this.icon);
  final String title;
  final IconData icon;
}

const List<Destination> allDestinations = <Destination>[
  Destination('Home', Icons.home),
  Destination('Songs', Icons.music_note),
  Destination('Profile', Icons.person),
];
