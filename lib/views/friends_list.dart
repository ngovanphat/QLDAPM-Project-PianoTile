import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/model/friend.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  FirebaseUser _user;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  Friend friend = new Friend('', '', '', '');
  Widget content;
  TextEditingController nameController = TextEditingController();
  List<Friend> _friends = [];

  loadFriend() async {
    _user = await FirebaseAuth.instance.currentUser();

    _friends.clear();
    await friend.getUserFriendsListByID();
    _friends = friend.getFriendList();

    return _friends;
  }

  removeFriend(int index) {
    database
        .reference()
        .child("Friendships")
        .child(_user.uid)
        .child(_friends[index].getFriendUID())
        .remove()
        .then((_) {
      setState(() {
        _friends.removeAt(index);
      });
    });

    database
        .reference()
        .child("Friendships")
        .child(_friends[index].getFriendUID())
        .child(_user.uid)
        .remove();
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    var friend = _friends[index];
    return new ListTile(
      leading: new Hero(
        tag: index,
        child: new CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage: new NetworkImage(friend.getAvatar()),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: new Text(
          friend.getName(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
      subtitle: new Text(
        '',
        //'Lv. ' + friend.getLevel(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      trailing: FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.white, width: 1)),
        child: Text(
          'Remove',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        color: Colors.white24,
        onPressed: () {
          showAlertDialog(context, index);
        },
      ),
    );
  }

  showAlertDialog(BuildContext context, int index) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Remove",
        style: TextStyle(
          color: Colors.red,
        ),
      ),
      onPressed: () {
        removeFriend(index);
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pop(true);
              });
              return AlertDialog(
                  shape: CircleBorder(
                    side: BorderSide(color: Colors.white, width: 2),
                  ),
                  backgroundColor: const Color(0xff004d00),
                  content: Container(
                      child: Icon(
                    Icons.done,
                    color: Colors.white,
                    size: 50,
                  )));
            });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.white, width: 1),
      ),
      backgroundColor: Colors.black,
      title: Center(
        child: Text(
          "Remove Friend?",
          style: TextStyle(color: Colors.white),
        ),
      ),
      content: Text(
        "Are you sure you want to remove this friend from your list?",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: const Color(0xff004466),
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: const Color(0xff004466),
        title: new Text('FRIENDS'),
      ),
      body: FutureBuilder(
          future: loadFriend(),
          builder: (context, AsyncSnapshot snapshot) {
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
                      ListView.builder(
                        itemCount: _friends.length,
                        itemBuilder: _buildFriendListTile,
                      ),
                    ],
                  ),
                ),
              );
            }
          }),
    );
  }
}
