import 'package:flutter/material.dart';

// import lib of us
import 'package:audioplayers/audio_cache.dart';
import 'package:piano_tile/helper/song_provider.dart';
import 'package:piano_tile/model/note.dart';
import 'package:piano_tile/model/line_divider.dart';
import 'package:piano_tile/model/line.dart';
import 'package:piano_tile/model/pause_menu.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter/services.dart';

import 'package:piano_tile/views/game_play.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class GamePlayOnline extends GamePlay {

  @override
  GamePlayOnlineState createState() => GamePlayOnlineState();

}

class GamePlayOnlineState extends GamePlayState<GamePlayOnline>{

  DatabaseReference refRoom;
  String roomName = null;
  String currentUsernameKey = null;
  String currentRank = null;
  List<String> listUsernameKey = [
    'usernameOne',
    'usernameTwo',
    'usernameThree',
    'usernameFour'
  ];
  List<int> listPoints = [0,0,0,0];
  List<UserPoint> listUserPoints = new List(4);
  List<String> listRanks = [
    '1st',
    '2nd',
    '3rd',
    '4th'
  ];
  var subscriptionPoints = null;


  @override
  Future<String> doInitNotes() async {

    await getRoomInfo();

    return await super.doInitNotes();
  }

  Future<String> getRoomInfo() async{
    // get firebase database reference
    refRoom = FirebaseDatabase.instance.reference().child('Room');

    // join room if not join yet
    if(roomName == null){
      roomName = 'GENERAL';
    }

    DataSnapshot snapshot = await refRoom.child(roomName).once();
    if(snapshot != null){
      print('[game_play_online] Connected to firebase room ${snapshot.value}');
      Map<dynamic, dynamic> rows = snapshot.value;


      // get username order
      for(var i = 0; i < listUsernameKey.length; i++){

        var username = rows[listUsernameKey[i]];
        if(username == null || username == ''){

          // this means i should get this slot
          currentUsernameKey = listUsernameKey[i];

          // save my username to slot
          refRoom.child(roomName).update({currentUsernameKey: 'foo'});
          refRoom.child(roomName).update({currentUsernameKey + 'Points': 0});

          print('[game_play_online] got slot: ${currentUsernameKey}');

          break;
        }

      }

      if(currentUsernameKey == null || currentUsernameKey == ''){
        // this means room is full
        // show dialog to exit
        // ...
      }

      // get song name (.mid.txt)
      String nameOfSong = null;
      rows.forEach((key, value) {
        if(key == 'musicName'){

          nameOfSong = value;
          print('[game_play_online] found song: ${nameOfSong}');
        }
      });

      // find song in song list
      // to find its filename
      DatabaseReference refSong = FirebaseDatabase
          .instance
          .reference()
          .child('Songs');

      bool isFound = false;
      DataSnapshot snapshot1 = await refSong.child('NhacViet').once();
      Map<dynamic,dynamic> songs = snapshot1.value;
      songs.forEach((key, value){

        if(value['name'] == nameOfSong){
          super.songName = value['filename'];
          print('[online] filename of song: ${super.songName}');
          isFound = true;
        }
      });
      if(isFound == false){

        // try found in Nhac Nuoc Ngoai
        snapshot1 = await refSong.child('NhacNuocNgoai').once();
        songs = snapshot1.value;
        songs.forEach((key, value){

          if(value['name'] == nameOfSong){
            super.songName = value['filename'];
            print('[online] filename of song: ${super.songName}');
            isFound = true;
          }
        });

      }


      // subscribe room to listen point changes
      subscriptionPoints = refRoom
          .child(roomName)
          .onValue
          .listen((event) {

        Map<dynamic, dynamic> rowsChanged = event.snapshot.value;

        // update to local list points
        for(var i = 0; i < listPoints.length; i++){
          listPoints[i] = rowsChanged[listUsernameKey[i]+'Points'];
        }

        // resolve
        currentRank = resolveRank(super.points, listPoints);

      });

    }; // end of snapshot

    return 'done';
  }

  @override
  drawPoints() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 32,
        ),
        child: Text(
          "$points, $currentRank",
          style: TextStyle(
            color: Colors.red,
            fontSize: 60,
          ),
        ),
      ),
    );
  }

  @override
  void onTap(Note note) {

    super.onTap(note);

    // update points to server
    refRoom.child(roomName).update({
      currentUsernameKey+"Points": super.points
    });
  }

  String resolveRank(int myPoints, List<int> listPoints) {

    // sort
    listPoints.sort((a,b){
      return b.compareTo(a);
    });

    // resolve my rank
    String rank = null;
    for(var i = 0; i < listPoints.length; i++){
      if(listPoints[i] == myPoints){
        rank = listRanks[i];
        break;
      }
    }

    return rank;
  }


  Future<String> calculateRank() async{

    // gather points of other players at the moment
    DataSnapshot snapshot = await refRoom.child(roomName).once();
    if(snapshot != null){
      Map<dynamic, dynamic> rows = snapshot.value;

      // store points
      for(var i = 0; i < listUsernameKey.length; i++){
//        listPoints[i] = rows[listUsernameKey[i]+'Points'];
        listUserPoints[i] = new UserPoint();
        listUserPoints[i].userNameKey = listUsernameKey[i];
        listUserPoints[i].username = rows[listUsernameKey[i]];
        listUserPoints[i].points = rows[listUsernameKey[i] + 'Points'];
      }
//      var myPoints = rows[currentUsernameKey+'Points'];
//      currentRank = resolveRank(myPoints, listPoints);

      // sort userPoints
      listUserPoints.sort(
              (a,b) => b.points.compareTo(a.points)
      );

    }

    return 'done';
  }


  @override
  void showFinishDialog() {

    calculateRank().then((value) {

      print('[online] making table');
      // make table with ordered points
      List<TableRow> rows = [];
      rows.add(
        TableRow( children: [
        Column(children:[
          Text('Rank',
            style: TextStyle(fontWeight: FontWeight.bold),)
        ]),
        Column(children:[
          Text('Name',
            style: TextStyle(fontWeight: FontWeight.bold),)
        ]),
        Column(children:[
          Text('Points',
            style: TextStyle(fontWeight: FontWeight.bold),)
        ]),
      ])
      );
      print('[online] making table row1');
      for(var i = 0; i < listUserPoints.length; i++){

        TextStyle style = null;
        if(listUserPoints[i].userNameKey == currentUsernameKey){
          style = TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold);
        }

        rows.add(

            TableRow( children: [
              Text('${listRanks[i]}',
                style: style,
                textAlign: TextAlign.center,
              ),
              Text('${listUserPoints[i].username}',
                style: style,
                textAlign: TextAlign.center,
              ),
              Text('${listUserPoints[i].points}',
                style: style,
                textAlign: TextAlign.center,
              ),
            ])
        );
      }
      print('[online] making table all rows');
      Table tableRanks = Table(
        border: TableBorder(),
        children: rows
      );

      print('[online] making table table');

      // show table in dialog
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Results"),
            content: SingleChildScrollView(
              child: tableRanks
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              )
            ],
          );
        },
      ).then((_) {

        // clean up
        doCleanUp();


        // return to home page or room page
        Navigator.pop(context);
//        Navigator.of(context).popUntil(
//                (route) => route.settings.name == "/home"
//        );

      });

    });


  }

  void doCleanUp(){
    // clear username
    refRoom.child(roomName).update({currentUsernameKey: ''});
    refRoom.child(roomName).update({currentUsernameKey+'Points': 0});

    // un-subscribe
    subscriptionPoints.cancel();
  }

}


class UserPoint{

  String userNameKey;
  String username;
  int points;
}


