import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Friend {
  String myUID;
  String name;
  String level;
  String avatar;
  List<Friend> _friends = [];
  final FirebaseDatabase database = FirebaseDatabase.instance;

  Friend(name, level, avatar) {
    this.name = name;
    this.level = level;
    this.avatar = avatar;
  }

  List<Friend> getFriendList() {
    return this._friends;
  }

  String getName() {
    return this.name;
  }

  String getUID() {
    return this.myUID;
  }

  void setName(String name) {
    this.name = name;
  }

  String getLevel() {
    return this.level;
  }

  void setLevel(String level) {
    this.level = level;
  }

  String getAvatar() {
    return this.avatar;
  }

  void setAvatar(String avatar) {
    this.avatar = avatar;
  }

  getUserFriendsListByID() async {
    final FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    myUID = _user.uid;
    await database
        .reference()
        .child("Friendships")
        .child(myUID)
        .once()
        .then(((value) => fromSnapshot(value)));
  }

  fromSnapshot(DataSnapshot snapshot) {
    try {
      for (var value in snapshot.value.values) {
        _friends.add(new Friend(value["name"], value["lv"], value["avatar"]));
      }
    } catch (e) {
      print(e);
    }
  }
}
