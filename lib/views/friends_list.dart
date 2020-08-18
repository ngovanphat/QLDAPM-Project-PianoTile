import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/model/friend.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  List<Friend> _friends = loadFriend();

  Widget _buildFriendListTile(BuildContext context, int index) {
    var friend = _friends[index];
    return new ListTile(
      leading: new Hero(
        tag: index,
        child: new CircleAvatar(
          radius: 30,
          backgroundColor: Colors.white,
          backgroundImage: new AssetImage(friend.avatar),
        ),
      ),
      title: new Text(
        friend.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      subtitle: new Text(
        'Lv. ' + friend.level,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
        ),
      ),
      trailing: FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(70),
            side: BorderSide(
                color: Colors.white, width: 2)),
        child: Text(
          'Remove',
          style: TextStyle(
              fontSize: 18, color: Colors.white),
        ),
        color: Colors.white24,
        onPressed: () {
          setState(() {
            _friends.removeAt(index);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_friends.isEmpty) {
      content = new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      content = new ListView.builder(
        itemCount: _friends.length,
        itemBuilder: _buildFriendListTile,
      );
    }

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
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
              content,
            ],
          ),
        ),
      ),
    );
  }
}

List loadFriend() {
  final names = [
    'Phat Ngo',
    'Thuan Nam',
    'Hanh Dung',
    'Thang Bui',
    'Minh Thuong',
    'Minh Quann',
    'Phat Ngo',
    'Thuan Nam',
    'Hanh Dung',
    'Thang Bui',
    'Minh Thuong',
    'Minh Quann'
  ];
  final levels = ['1', '2', '3', '4', '5', '6','1', '2', '3', '4', '5', '6'];
  final avatars = [
    'assets/images/male.png',
    'assets/images/male.png',
    'assets/images/female.png',
    'assets/images/male.png',
    'assets/images/male.png',
    'assets/images/male.png',
    'assets/images/male.png',
    'assets/images/male.png',
    'assets/images/female.png',
    'assets/images/male.png',
    'assets/images/male.png',
    'assets/images/male.png',
  ];

  final List<Friend> friendList = [];
  for (var i = 0; i < names.length; i++) {
    friendList.add(new Friend(names[i], levels[i], avatars[i]));
  }

  return friendList;
}
