import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/model/user.dart';

// ignore: must_be_immutable
class AddFriendProfile extends StatefulWidget {
  User user;
  String myUID;

  AddFriendProfile({Key key, @required this.user, this.myUID})
      : super(key: key);

  @override
  _AddFriendProfileState createState() => _AddFriendProfileState();
}

class _AddFriendProfileState extends State<AddFriendProfile> {
  FirebaseUser _user;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  Widget requestButton, declineButton;
  bool isVisible = false;
  String state = 'not_friends';
  String text = 'SEND FRIEND REQUEST';

  buttonState() async {
    try {
      _user = await FirebaseAuth.instance.currentUser();
      await database
          .reference()
          .child("FriendRequest")
          .child(widget.myUID)
          .child(widget.user.getMyUID())
          .once()
          .then((value) {
        try {
          String temp = value.value["request_type"];
          if (temp == 'sent') {
            state = 'request_sent';
            text = 'CANCEL FRIEND REQUEST';
          } else if (temp == 'received') {
            state = 'request_received';
            text = 'ACCEPT FRIEND REQUEST';
            isVisible = true;
          }
        } catch (e) {
          //state = 'friends';
          //text = 'WE ARE FRIENDS!';
          //print(e);
        }
      });
    } catch (e) {
      //print(e);
    }
    return true;
  }

  handleFriendRequest() {
    if (state == 'not_friends') {
      database
          .reference()
          .child("FriendRequest")
          .child(widget.myUID)
          .child(widget.user.getMyUID())
          .set({"request_type": "sent"});

      database
          .reference()
          .child("FriendRequest")
          .child(widget.user.getMyUID())
          .child(widget.myUID)
          .set({"request_type": "received"});

      state = 'request_sent';
      text = 'CANCEL FRIEND REQUEST';
    } else if (state == 'request_sent') {
      database
          .reference()
          .child("FriendRequest")
          .child(widget.myUID)
          .child(widget.user.getMyUID())
          .remove();

      database
          .reference()
          .child("FriendRequest")
          .child(widget.user.getMyUID())
          .child(widget.myUID)
          .remove();

      state = 'not_friends';
      text = 'SEND FRIEND REQUEST';
    } else if (state == 'request_received') {
      database
          .reference()
          .child("Friendships")
          .child(widget.myUID)
          .child(widget.user.getMyUID())
          .set({
        "id": widget.user.getMyUID(),
        "name": widget.user.getName(),
        "avatar": widget.user.getAvatar(),
        "lv": "10"
      });

      database
          .reference()
          .child("Friendships")
          .child(widget.user.getMyUID())
          .child(widget.myUID)
          .set({
        "id": _user.uid,
        "name": _user.displayName,
        "avatar": _user.photoUrl,
        "lv": "10"
      });

      database
          .reference()
          .child("FriendRequest")
          .child(widget.myUID)
          .child(widget.user.getMyUID())
          .remove();

      database
          .reference()
          .child("FriendRequest")
          .child(widget.user.getMyUID())
          .child(widget.myUID)
          .remove();

      state = 'friends';
      text = 'WE ARE FRIENDS!';
    }
  }

  declineFriendRequest() {
    database
        .reference()
        .child("FriendRequest")
        .child(widget.myUID)
        .child(widget.user.getMyUID())
        .remove();

    database
        .reference()
        .child("FriendRequest")
        .child(widget.user.getMyUID())
        .child(widget.myUID)
        .remove();

    state = 'not_friends';
    text = 'SEND FRIEND REQUEST';

    isVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff004466),
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            setState(() {
              Navigator.of(context).pop();
            });
          },
        ),
        backgroundColor: const Color(0xff004466),
        title: new Text('PROFILE'),
      ),
      body: FutureBuilder(
        future: buttonState(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            return SafeArea(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: <Widget>[
                    Image.asset('assets/images/background.jpg',
                        fit: BoxFit.cover),
                    Container(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                widget.user.getAvatar(),
                              ),
                              radius: 50,
                              backgroundColor: Colors.transparent,
                            ),
                            SizedBox(height: 40),
                            Text(
                              'NAME',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70),
                            ),
                            Text(
                              widget.user.getName(),
                              style: TextStyle(
                                  fontSize: 23,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'EMAIL',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70),
                            ),
                            Text(
                              widget.user.getEmail(),
                              style: TextStyle(
                                  fontSize: 23,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 40),
                            requestButton = SizedBox(
                              width: 300,
                              height: 50,
                              child: new FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: Text(
                                  text,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                color: Color(0xff004d00),
                                onPressed: () {
                                  setState(() {
                                    handleFriendRequest();
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: 20),
                            declineButton = Visibility(
                              visible: isVisible,
                              child: SizedBox(
                                width: 300,
                                height: 50,
                                child: new FlatButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: Text(
                                    'DECLINE FRIEND REQUEST',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  color: Color(0xffff0000),
                                  onPressed: () {
                                    setState(() {
                                      declineFriendRequest();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
