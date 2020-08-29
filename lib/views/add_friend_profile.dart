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
  final FirebaseDatabase database = FirebaseDatabase.instance;

  Widget requestButton;
  String state = 'not_friends';
  String text = 'SEND FRIEND REQUEST';

  buttonState() async {
    try {
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
          }
        } catch (e) {
          print(e);
        }
      });
    } catch (e) {
      print(e);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff004466),
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
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
