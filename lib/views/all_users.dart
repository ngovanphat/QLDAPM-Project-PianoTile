import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/model/user.dart';
import 'package:piano_tile/views/add_friend_profile.dart';
import 'package:piano_tile/model/friend.dart';

class AllUsers extends StatefulWidget {
  @override
  _AllUsersState createState() => _AllUsersState();
}

class _AllUsersState extends State<AllUsers> {
  final FirebaseDatabase database = FirebaseDatabase.instance;
  String myUID;
  User user = new User('', '', '', '');
  Friend friend = new Friend('', '', '', '');
  Widget content;
  TextEditingController nameController = TextEditingController();
  List<User> _users = [];
  List<Friend> _friends = [];

  loadUsers() async {
    _users.clear();
    await user.getAllUsers();
    _users = user.getFriendList();

    _friends.clear();
    await friend.getUserFriendsListByID();
    _friends = friend.getFriendList();

    myUID = user.getMyUID();
    _users.removeWhere((item) => item.getMyUID() == myUID);

    for (int i = 0; i < _friends.length; i++) {
      _users
          .removeWhere((item) => item.getMyUID() == _friends[i].getFriendUID());
    }



    return _users;
  }

  toProfile(int index) {
    User user = _users[index];

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AddFriendProfile(user: user, myUID: myUID);
        },
      ),
    );
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    var user = _users[index];
    return new ListTile(
      leading: new Hero(
        tag: index,
        child: new CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage: new NetworkImage(user.getAvatar()),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: new Text(
          user.getName(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
      subtitle: new Text(
        '',
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
          'Profile',
          style: TextStyle(fontSize: 14, color: Colors.white),
        ),
        color: Colors.white24,
        onPressed: () {
          toProfile(index);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: const Color(0xff004466),
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: const Color(0xff004466),
        title: new Text('ALL USERS'),
      ),
      body: FutureBuilder(
          future: loadUsers(),
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
                        itemCount: _users.length,
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
