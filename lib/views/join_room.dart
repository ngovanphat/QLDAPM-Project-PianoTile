import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:piano_tile/model/room.dart';
import 'package:piano_tile/model/widget.dart';
import 'package:piano_tile/views/game_play_online.dart';
import 'package:piano_tile/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piano_tile/helper/sharedPreferencesDefinition.dart';


class JoinRoom extends StatefulWidget {
  final String roomKey;

  JoinRoom({Key key, String this.roomKey}) : super(key: key);
  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  bool isInRoom = true;
  AnimationController animationController;
  Room room;
  FirebaseUser user;

  Future<void> loadRoom(String key) async {
    room = new Room(key, '', '', '', '', '');
    await room.getRoomByID(key);
    user = await FirebaseAuth.instance.currentUser();
    await savePreferences(
        userId: user.displayName, roomId: widget.roomKey, isHost: false);
    setState(() {
      print("load done");
      isLoading = false;
    });
  }

  Future<void> savePreferences(
      {String userId, String roomId, bool isHost}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString(sharedPrefKeys.getRoomIdKey(), roomId);
    prefs.setBool(sharedPrefKeys.getIsRoomHostKey(), isHost);
  }

  @override
  void initState() {
    super.initState();
    animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat();
    //print(widget.roomKey+" is room key");
    loadRoom(widget.roomKey);
    try {
      Timer.periodic(Duration(seconds: 10), (timer) {
        room.triggerReadFromDB(widget.roomKey);
        setState(() {
          isInRoom = true;
        });
        if (room.usernameOne == '')
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Home()));
        else if (room.isPlaying == true)
//          Navigator.pushReplacement(context,
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => GamePlayOnline()));
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    animationController.dispose();
    room.removeUserByName(user.displayName);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container(
            color: Colors.white,
            child: Center(
              child: SpinKitWave(
                color: Colors.blue,
                size: 50.0,
              ),
            ),
          )
        : Scaffold(
            backgroundColor: const Color(0xff004466),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: double.infinity,
              child: Stack(
                fit: StackFit.passthrough,
                children: [
                  Image.asset('assets/images/background.jpg', fit: BoxFit.fill),
                  Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 50),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    'ROOM ID: ${room.keyOfRoom}',
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            AnimatedBuilder(
                              animation: animationController,
                              builder: (_, child) {
                                return Transform.rotate(
                                  angle: animationController.value * 1 * 3.14,
                                  child: child,
                                );
                              },
                              child: Image.asset('assets/images/disk.png'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Text(
                                    '${room.musicName}',
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 23),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  userInRoom(context, room.usernameOne),
                                  room.usernameTwo != ''
                                      ? userInRoom(context, room.usernameTwo)
                                      : GestureDetector(
                                          child: userInRoom(context, '+'),
                                          onTap: () {
                                            print("press add button");
                                          },
                                        ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  room.usernameThree != ''
                                      ? userInRoom(context, room.usernameThree)
                                      : GestureDetector(
                                          child: userInRoom(context, '+'),
                                          onTap: () {
                                            print("press add button");
                                          },
                                        ),
                                  room.usernameFour != ''
                                      ? userInRoom(context, room.usernameFour)
                                      : GestureDetector(
                                          child: userInRoom(context, '+'),
                                          onTap: () {
                                            print("press add button");
                                          },
                                        ),
                                ],
                              ),
                            ),
                          ]))
                ],
              ),
            ),
          );
  }
}
