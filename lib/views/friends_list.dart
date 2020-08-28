import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/model/friend.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  String myUID;
  Friend friend = new Friend('', '', '');
  Widget content;
  TextEditingController nameController = TextEditingController();
  List<Friend> _friends = [];

  loadFriend() async {
    _friends.clear();
    await friend.getUserFriendsListByID();
    _friends = friend.getFriendList();
    myUID = friend.getUID();
    return _friends;
  }

  addItemToList() {
    setState(() {
      _friends.insert(
        0,
        new Friend(nameController.text, '1', 'assets/images/female.png'),
      );
    });
  }

  removeItemFromList(int index) {
    database
        .reference()
        .child("Friendships")
        .child(myUID)
        .child("friend_${index+1}")
        .remove()
        .then((_) {
      setState(() {
        _friends.removeAt(index);
      });
    });
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
      title: new Text(
        friend.getName(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      subtitle: new Text(
        'Lv. ' + friend.getLevel(),
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
        removeItemFromList(index);
        Navigator.of(context).pop();
        showDialog(
            context: context,
            builder: (BuildContext context) {
              Future.delayed(Duration(seconds: 1), () {
                Navigator.of(context).pop(true);
              });
              return AlertDialog(
                  shape: CircleBorder(
                    side: BorderSide(
                        color: Colors.white, width: 2),
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
        title: Center(
          child: new Text('FRIENDS'),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 30),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    backgroundColor: Colors.white,
                    title: Center(
                      child: Text(
                        "Add Friend?",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    content: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'User Name',
                      ),
                    ),
                    actions: [
                      FlatButton(
                        child: Text("Send Request"),
                        onPressed: () {
                          addItemToList();
                          nameController.clear();
                          Navigator.of(context).pop();
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                Future.delayed(Duration(seconds: 1), () {
                                  Navigator.of(context).pop(true);
                                });
                                return AlertDialog(
                                    shape: CircleBorder(
                                      side: BorderSide(
                                          color: Colors.white, width: 2),
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
                      )
                    ],
                  );
                },
              );
            },
          )
        ],
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
