
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'package:piano_tile/helper/sizes_helpers.dart';
import 'package:piano_tile/model/room.dart';
import 'package:piano_tile/model/widget.dart';
import 'package:piano_tile/views/game_play_online.dart';
import 'package:piano_tile/views/music_list.dart';
import 'package:random_string/random_string.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math' show Random;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piano_tile/model/custom_expansion_panel.dart' as CustomExpansionPanel;
import 'package:piano_tile/model/Song.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';


class CreateRoom extends StatefulWidget {
  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  String musicName = "Tìm lại bầu trời";
  String username = 'ngophat99';
  Room room;
  bool isInRoom = true;
  List<Song> songs = [];

  List getSongs() {
    //TODO fetch data from server
    //tên bài hát
    final titles = [
      'Little Star',
      'Jingle Bells',
      'Canon',
      'Two Tigers',
      'The Blue Danube',
      'Happy New Year',
      'Beyer No. 8',
      'Bluestone Alley',
      'Reverie'
    ];
    //tên ca sĩ/nhóm nhạc
    final artists = [
      'English Folk Music',
      'James Lord Pierpont',
      'Johann Pachelbel',
      'French Folk Music',
      'Johann Strauss II',
      'English Folk Music',
      'Ferdinand Beyer',
      'Congfei Wei',
      'Claude Debussy'
    ];
    //icons sẽ được thay bằng hình nhạc sau
    final images = [
      'assets/images/music-note.png',
      'assets/images/music-note.png',
      'assets/images/music-note.png',
      'assets/images/music-note.png',
      'assets/images/music-note.png',
      'assets/images/music-note.png',
      'assets/images/music-note.png',
      'assets/images/music-note.png',
      'assets/images/music-note.png'
    ];
    final List<int> difficulties = [1, 1, 1, 2, 3, 4, 4, 5, 5];

    final List<Song> musicList = [];
    for (var i = 0; i < titles.length; i++) {
      musicList.add(new Song(
          i.toString(), titles[i], [artists[i]], difficulties[i], images[i]));
    }
    return musicList;
  }

  @override
  void initState() {
    super.initState();
    _animationController =
    new AnimationController(vsync: this, duration: Duration(seconds: 1))
      ..repeat();
    String key= randomString(6,from: 65,to: 90);
    room = new Room(key, musicName, username, '', '', '');
    room.updateToDatabase(key);
    songs = getSongs();

    // update additional fields: usernameOnePoints, usernameTwoPoints,...
    // for storing user points
    saveAdditionalFields(roomId: key);

    // write to preferences
    // for later retrieving in other screens
    savePreferences(userId: username, roomId: key, isHost: true);
    print('[creat_room] done update database and save preferences');
  }

  Future<void> saveAdditionalFields({String roomId}) async{
    var ref = FirebaseDatabase.instance.reference().child('Room')
        .child(roomId);
    ref.update({"usernameOnePoints": 0});
    ref.update({"usernameTwoPoints": 0});
    ref.update({"usernameThreePoints": 0});
    ref.update({"usernameFourPoints": 0});

  }

  Future<void> savePreferences({String userId, String roomId, bool isHost}) async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', userId);
    prefs.setString('roomId', roomId);
    prefs.setBool('isRoomHost', isHost);
  }

  @override
  void deactivate() {
    super.deactivate();

    room.removeUserByName(username);
  }
  dialogContent(BuildContext context){
    return Stack(
      children: <Widget>[
        Text("sorry"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(Duration(seconds: 5), (timer) {
      room.triggerReadFromDB(room.keyOfRoom);
      this.setState(() {
        this.isInRoom = true;
      });
    });
    return Scaffold(
      backgroundColor: const Color(0xff004466),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Image.asset('assets/images/background.jpg', fit: BoxFit.fill),
            RowOnTop(context, 0, 0),
            Container(
                margin: EdgeInsets.only(top: 70),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('ROOM ID: ${room.keyOfRoom}',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),

                            )
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (_, child) {
                          return Transform.rotate(
                            angle: _animationController.value * 1 * 3.14,
                            child: child,
                          );
                        },
                        child: Image.asset('assets/images/disk.png'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Text(
                             '${musicName}',
                              style: TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 13),
                            child: IconButton(
                              icon: Icon(Icons.arrow_drop_down_circle),
                              tooltip: 'Open Music List',
                              onPressed: () {
                                songs = getSongs();
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Select song'),
                                        scrollable: true,
                                        content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                height: 700.0,
                                                width: 600.0,
                                                child: ListView.builder(
                                                  itemCount: songs.length,
                                                  itemBuilder: (context, index) {
                                                    return GestureDetector(
                                                        onTap: () {
                                                          setState(() { musicName = songs[index].getName(); });
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: Card(
                                                          child: ListTile(
                                                            isThreeLine: true,
                                                            leading: Container(
                                                              height: double.infinity,
                                                              child: ImageIcon(
                                                                AssetImage(songs[index].getImage()),
                                                                size: 50,
                                                                color: Color(0xFF3A5A98),
                                                              ), //replaced by image if available
                                                            ),
                                                            title: Text(songs[index].getName()),
                                                            subtitle: Container(
                                                              child: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: <Widget>[
                                                                  Flexible(
                                                                    flex: 3,
                                                                    child: Container(
                                                                      height: 30,
                                                                      child: new MarqueeWidget(
                                                                        text: songs[index].getArtists().join('-'),
                                                                        textStyle: new TextStyle(fontSize: 16.0),
                                                                        scrollAxis: Axis.horizontal,
                                                                      ),
                                                                      //Text(,overflow: TextOverflow.ellipsis,),
                                                                    ),
                                                                  ),
                                                                  Flexible(
                                                                    flex: 3,
                                                                    child: SmoothStarRating(
                                                                      rating: songs[index].getDifficulty().toDouble(),
                                                                      size: 18,
                                                                      filledIconData: Icons.music_note,
                                                                      defaultIconData: null,
                                                                      starCount: 5,
                                                                      isReadOnly: true,
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ));
                                                  },
                                                ),
                                              )
                                            ]
                                        ),
                                      );
                                    }
                                );
                              },
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 23),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            userInRoom(context, room.usernameOne),
                            room.usernameTwo != '' ? userInRoom(context, room.usernameTwo) : GestureDetector(
                              child:  userInRoom(context, '+'),
                              onTap: (){
                                  print("press add button");
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                           room.usernameThree != '' ? userInRoom(context, room.usernameThree) : GestureDetector(
                             child:  userInRoom(context, '+'),
                             onTap: (){
                               print("press add button");
                             },
                           ),
                          room.usernameFour!= '' ? userInRoom(context, room.usernameFour) : GestureDetector(
                            child:  userInRoom(context, '+'),
                            onTap: (){
                              print("press add button");
                            },
                          ),
                          ],
                        ),
                      ),
                      Container(
                        width: 350,
                        height: 55,
                        margin: EdgeInsets.only(top: 20),
                        child: FlatButton(
                          onPressed: () {
//                            Navigator.pushReplacement(
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => GamePlayOnline()));
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(70),
                              side: BorderSide(
                                  color: Colors.white, width: 3)),
                          child: Text(
                            'Play',
                            style: TextStyle(
                                fontSize: 25, color: Colors.white),
                          ),
                          color: Colors.white24,
                        ),
                      )
                    ]))
          ],
        ),
      ),
    );
  }
}

