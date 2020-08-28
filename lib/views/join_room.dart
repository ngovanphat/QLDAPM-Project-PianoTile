import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:piano_tile/model/room.dart';
import 'package:piano_tile/model/widget.dart';
import 'package:piano_tile/views/home.dart';

class JoinRoom extends StatefulWidget {
  final String roomKey;

  JoinRoom({Key key,String this.roomKey}):super(key: key);
  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> with SingleTickerProviderStateMixin{

  bool isLoading = true;
  bool isInRoom = true;
  AnimationController animationController;
  Room room;
  FirebaseUser user;


  Future<void> loadRoom(String key) async {
    room =  new Room(key,'','','','','');
    await room.getRoomByID(key);
    user = await FirebaseAuth.instance.currentUser();
    setState(() {
      print("load done");
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(vsync: this, duration: Duration(seconds: 1))..repeat();
    //print(widget.roomKey+" is room key");
    loadRoom(widget.roomKey);
  }


  @override
  void deactivate() {
    super.deactivate();
    room.removeUserByName(user.displayName);
  }

  @override
  Widget build(BuildContext context) {
    try
    {
      Timer.periodic(Duration(seconds: 10), (timer) {
        room.triggerReadFromDB(widget.roomKey);
        setState(() {
          isInRoom = true;
        });
        if(room.usernameOne=='')Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => Home()
        ));
      });
    }catch(e){
      print(e);
    }
    return isLoading ? Container(
      color: Colors.white,
      child: Center(
        child: SpinKitWave(
          color: Colors.blue,
          size: 50.0,
        ),
      ),
    ) : Scaffold(
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
                margin: EdgeInsets.only(top: 70),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
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
