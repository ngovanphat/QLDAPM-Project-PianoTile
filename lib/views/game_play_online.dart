import 'dart:async';

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
import 'package:path_provider/path_provider.dart';


import 'package:shared_preferences/shared_preferences.dart';

class GamePlayOnline extends GamePlay {

  @override
  GamePlayOnlineState createState() => GamePlayOnlineState();

}

class GamePlayOnlineState extends GamePlayState<GamePlayOnline>{

  DatabaseReference refRoom;
  String roomName = null;
  String currentUsername = null;
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

    // get my information from file
    // include: username, current room name
    await getMyInfo();

    // then get room Information
    // include: song name, other players name, points
    await getRoomInfo();

    // download note file and make note list
    return await super.doInitNotes();
  }

  Future<String> getMyInfo() async {

    // read from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    this.currentUsername = prefs.getString('userId') ?? "foo";
    this.roomName = prefs.getString('roomId') ?? "GENERAL";

    return 'done';
  }

  Future<String> getRoomInfo() async{
    // get firebase database reference
    refRoom = FirebaseDatabase.instance.reference().child('Room');


    DataSnapshot snapshot = await refRoom.child(roomName).once();
    if(snapshot != null){
      print('[game_play_online] Connected to firebase room ${snapshot.value}');
      Map<dynamic, dynamic> rows = snapshot.value;


      // find  username<order> of me
      currentUsernameKey = findUsernameKey(rows, currentUsername);
      print('[game_play_online] usernameKey: $currentUsername');

      if(currentUsernameKey == null || currentUsernameKey == ''){
        // this means room is full
        // show dialog to exit
        // ...
      }


      // get song name (.mid.txt)
      String nameOfSong = findSongName(rows, 'musicName');
      print('[game_play_online] found song: ${nameOfSong}');


      // find song in song list
      // to find its filename
      DatabaseReference refSong = FirebaseDatabase
          .instance
          .reference()
          .child('Songs');

      DataSnapshot snapshot1 = await refSong.child('NhacViet').once();
      Map<dynamic,dynamic> songs = snapshot1.value;
      super.songName = findSongFileName(songs, nameOfSong);

      if(super.songName == null){

        // try found in Nhac Nuoc Ngoai
        snapshot1 = await refSong.child('NhacNuocNgoai').once();
        songs = snapshot1.value;
        super.songName = findSongFileName(songs, nameOfSong);

      }
      print('[online] filename of song: ${super.songName}');


      // subscribe room to listen point changes
      subscriptionPoints = subscribePointChanges(refRoom.child(roomName));

    }; // end of snapshot

    return 'done';
  }

  // find key that is holding currentUsername
  String findUsernameKey(Map<dynamic, dynamic> rows, String currentUsername){

    for(var i = 0; i < listUsernameKey.length; i++){

      var username = rows[listUsernameKey[i]];

      if(username == currentUsername){
        print(username);
        return listUsernameKey[i];

      }

    }
    return null;

  }

  // find song name at a certain key
  String findSongName(Map<dynamic, dynamic> rows, String key){
    return rows[key];
  }

  // find song filename from song list
  String findSongFileName(Map<dynamic, dynamic> songs, String nameOfSong){

    print('[online_findsongfilename] songs: $songs');
    String filename = null;
    songs.forEach((key, value){

      if(value['name'] == nameOfSong){
        filename =  value['filename'];
      }
    });

    return filename;
  }

  // subscribe listener to room data changes
  StreamSubscription subscribePointChanges(DatabaseReference refRoom){

    return refRoom
        .onValue
        .listen((event) {

      Map<dynamic, dynamic> rowsChanged = event.snapshot.value;

      // update to local list points
      for(var i = 0; i < listPoints.length; i++){
        listPoints[i] = rowsChanged[listUsernameKey[i]+'Points'];
      }

      // resolve
      currentRank = resolveLocalRank(super.points, listPoints);

    });
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

  String resolveLocalRank(int myPoints, List<int> listPoints) {

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


  Future<String> calculateFinalRank() async{

    // gather points of other players
    DataSnapshot snapshot = await refRoom.child(roomName).once();
    if(snapshot != null){
      Map<dynamic, dynamic> rows = snapshot.value;

      // store points
      for(var i = 0; i < listUsernameKey.length; i++){

        listUserPoints[i] = new UserPoint();
        listUserPoints[i].userNameKey = listUsernameKey[i];
        listUserPoints[i].username = rows[listUsernameKey[i]];
        listUserPoints[i].points = rows[listUsernameKey[i] + 'Points'];
      }

      // sort userPoints
      listUserPoints.sort(
              (a,b) => b.points.compareTo(a.points)
      );

    }

    return 'done';
  }

  TableRow makeTableRowHeaders(){

    return TableRow( children: [
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
    ]);
  }

  List<TableRow> makeTableRows(){

    List<TableRow> rows = [];
    rows.add(
        makeTableRowHeaders()
    );

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

    return rows;
  }

  @override
  void showFinishDialog({String status}) async {

    calculateFinalRank().then((value) {

      print('[online] making table');

      // make table with ordered points
      List<TableRow> rows = makeTableRows();
      Table tableRanks = Table(
        border: TableBorder(),
        children: rows
      );


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
                onPressed: () {

                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              )
            ],
          );
        },
      ).then((_) {

        // clean up
        doCleanUp();

        // return to previous page
        refRoom.child(roomName).child("isPlaying").set(false);
        Navigator.pop(context);

      });

    });


  }

  void doCleanUp(){

    // un-subscribe listening to room changes
    subscriptionPoints.cancel();
  }


  // disable pause in online-mode
  @override
  pauseButton() {
    return Container();
  }

}


class UserPoint{

  String userNameKey;
  String username;
  int points;
}


