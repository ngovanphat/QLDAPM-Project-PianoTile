import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/model/widget.dart';
import 'package:piano_tile/views/join_room.dart';

class Room{
  String keyOfRoom;
  String usernameOne,usernameTwo,usernameThree,usernameFour;
  String musicName;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  Room(this.keyOfRoom,this.musicName,this.usernameOne,this.usernameTwo,this.usernameThree,this.usernameFour);

   getRoomByID(String key) async{
    await database.reference().child("Room")
        .child(key)
        .once()
        .then((value) => fromSnapshot(value))
        .catchError((onError){
          print(onError);
        });
  }
  updateToDatabase(String key){
    database.reference().child("Room")
        .child(key)
        .update(this.toJson())
        .then((value) {print(key);})
        .catchError((onError){
        print(onError);
    });
  }
  fromSnapshot(DataSnapshot snapshot)
  {
    try {
      keyOfRoom = snapshot.value["keyOfRoom"];
      musicName = snapshot.value["musicName"];
      usernameOne = snapshot.value["usernameOne"];
      usernameTwo = snapshot.value["usernameTwo"];
      usernameThree = snapshot.value["usernameThree"];
      usernameFour = snapshot.value["usernameFour"];
    }
    catch (e){
      print(e);
    }
  }
  removeUserByName (String username) async{
    await getRoomByID(this.keyOfRoom);
    if(usernameOne == username) usernameOne = '';
    else if(usernameTwo == username) usernameTwo='';
    else if(usernameThree == username) usernameThree='';
    else if(usernameFour == username) usernameFour = '';
    updateToDatabase(keyOfRoom);
    if(usernameOne==''&&usernameTwo==''&&usernameThree==''&&usernameFour=='')removeRoom();
  }
  removeRoom(){
    database.reference().child("Room").child(keyOfRoom).remove();
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
  triggerReadFromDB(String key){
    database.reference().child("Room").child(key).onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      fromSnapshot(snapshot);
    });
  }

  static Future<bool> joinRoom(BuildContext context,String username, String key) async {
    Room room = new Room(key,'','','','','');
    await room.getRoomByID(key);
    if(room.usernameOne==''&&room.usernameTwo==''&&room.usernameThree==''&&room.usernameFour==''){
      showDialog(context: context, builder: (_) => customAlertDialog(context, 'Room is not exist'));
      return false;
    }
    if(room.usernameOne == ''){
      room.usernameOne = username;
    }
    else if (room.usernameTwo == '') {
      room.usernameTwo = username;
    }
    else if (room.usernameThree == ''){
      room.usernameThree = username;
    }
    else if (room.usernameFour == ''){
      room.usernameFour = username;
    }
    else {
      if(room.usernameOne!=''&&room.usernameTwo!=''&&room.usernameThree!=''&&room.usernameFour!=''){
          showDialog(
              context: context,
              builder: (_) => customAlertDialog(context, 'Room is full')
          );
          return false;
      }
    }
    room.updateToDatabase(key);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JoinRoom(),
    ));
    return true;
  }


}