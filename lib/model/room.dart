import 'package:firebase_database/firebase_database.dart';

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
        .set(this.toJson())
        .then((value) {print(key);})
        .catchError((onError){
        print(onError);
    });
  }
  fromSnapshot(DataSnapshot snapshot)
  {
    keyOfRoom = snapshot.value["keyOfRoom"];
    musicName = snapshot.value["musicName"];
    usernameOne = snapshot.value["usernameOne"];
    usernameTwo = snapshot.value["usernameTwo"];
    usernameThree = snapshot.value["usernameThree"];
    usernameFour = snapshot.value["usernameFour"];
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



}