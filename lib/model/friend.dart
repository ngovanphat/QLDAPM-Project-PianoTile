import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Friend {
  String name;
  String level;
  String avatar;
  final FirebaseDatabase database = FirebaseDatabase.instance;

  Friend(name, level, avatar) {
    this.name = name;
    this.level = level;
    this.avatar = avatar;
  }

  String getName() {
    return this.name;
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

  triggerReadFromDB() async {
    final FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    database
        .reference()
        .child("Friendships")
        .child(_user.uid)
        .child("friend_1")
        .onValue
        .listen((event) {
      DataSnapshot snapshot = event.snapshot;
      fromSnapshot(snapshot);
    });
  }

  getUserByID() async {
    final FirebaseUser _user = await FirebaseAuth.instance.currentUser();
    await database
        .reference()
        .child("Friendships")
        .child(_user.uid)
        .child("friend_1")
        .once()
        .then((value) => fromSnapshot(value))
        .catchError((onError) {
      print(onError);
    });
  }

  fromSnapshot(DataSnapshot snapshot) {
    try {
      name = snapshot.value["name"];
      level = snapshot.value["lv"];
      avatar = snapshot.value["avatar"];
      print(name);
    } catch (e) {
      print(e);
    }
  }
}
