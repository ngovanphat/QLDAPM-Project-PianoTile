
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/model/room.dart';
import 'package:piano_tile/model/widget.dart';
import 'package:piano_tile/views/game_play.dart';
import 'package:piano_tile/views/music_list.dart';
import 'package:random_string/random_string.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' show Random;

class CreateRoom extends StatefulWidget {
  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  String musicName = "Little Star";
  String username = 'ngophat99';
  Room room;
  bool isInRoom = true;


  @override
  void initState() {
    super.initState();
    _animationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..repeat();
    String key= randomString(6,from: 65,to: 90);
    room = new Room(key, musicName, username, '', '', '');
    room.updateToDatabase(key);
  }

  @override
  void deactivate() {
    super.deactivate();
    room.removeUserByName(username);
  }
  @override
  Widget build(BuildContext context) {
    Timer.periodic(Duration(seconds: 5), (timer) {
      room.triggerReadFromDB(room.keyOfRoom);
      this.setState(() {
        this.isInRoom = true;
      });
    });
    return Scaffold(
      backgroundColor: const Color(0xff004466),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Image.asset('assets/images/background.jpg', fit: BoxFit.fill),
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
                         '${room.musicName}',
                          style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            userInRoom(context, room.usernameOne),
                            userInRoom(context, room.usernameTwo != '' ? room.usernameTwo : '+'),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            userInRoom(context, room.usernameThree != '' ? room.usernameThree : '+'),
                            userInRoom(context, room.usernameFour != '' ? room.usernameFour : '+'),
                          ],
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
                                    builder: (context) => MusicList()));
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(70),
                              side: BorderSide(
                                  color: Colors.white, width: 3)),
                          child: Text(
                            'List Music',
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
                      )
                    ]))
          ],
        ),
      ),
    );
  }
}

