import 'package:firebase_database/firebase_database.dart';

class Room{
  String keyOfRoom;
  String usernameOne,usernameTwo,usernameThree,usernameFour;
  String musicName;

  Room(this.keyOfRoom,this.musicName,this.usernameOne,this.usernameTwo,this.usernameThree,this.usernameFour);

  Room.fromSnapshot(DataSnapshot snapshot)
  {
    keyOfRoom = snapshot.value["keyOfRoom"];
    musicName = snapshot.value["musicName"];
    usernameOne = snapshot.value["usernameOne"];
    usernameTwo = snapshot.value["usernameTwo"];
    usernameThree = snapshot.value["usernameThree"];
    usernameFour = snapshot.value["usernameFour"];
  }

  toJson() {
    return {
       "keyOfRoom": keyOfRoom,
        "musicName": musicName,
      "usernameOne": usernameOne,
      "usernameTwo": usernameTwo,
      "usernameThree": usernameThree,
      "usernameFour": usernameFour,
    };
  }



}