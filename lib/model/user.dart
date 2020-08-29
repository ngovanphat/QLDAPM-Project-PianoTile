import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class User {
  String myUID;
  String name;
  String avatar;
  String email;
  List<User> _users = [];
  final FirebaseDatabase database = FirebaseDatabase.instance;

  User(myUID, name, avatar, email) {
    this.myUID = myUID;
    this.name = name;
    this.avatar = avatar;
    this.email = email;
  }

  List<User> getFriendList() {
    return this._users;
  }

  String getName() {
    return this.name;
  }

  String getEmail() {
    return this.email;
  }

  String getMyUID() {
    return this.myUID;
  }

  void setName(String name) {
    this.name = name;
  }

  String getAvatar() {
    return this.avatar;
  }

  void setAvatar(String avatar) {
    this.avatar = avatar;
  }

  getAllUsers() async {
    _users.clear();
    final FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    myUID = _user.uid;
    await database
        .reference()
        .child("Users")
        .once()
        .then(((value) => fromSnapshot(value)));
  }

  fromSnapshot(DataSnapshot snapshot) {
    try {
      for (var value in snapshot.value.values) {
        _users.add(new User(
            value["id"], value["name"], value["avatar"], value["email"]));
      }
    } catch (e) {
      print(e);
    }
  }
}
