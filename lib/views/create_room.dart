import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'package:piano_tile/helper/local_db.dart';
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
import 'package:piano_tile/helper/sharedPreferencesDefinition.dart';
import 'package:piano_tile/model/custom_expansion_panel.dart'
    as CustomExpansionPanel;
import 'package:piano_tile/model/Song.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateRoom extends StatefulWidget {
  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  String musicName = "Nothing Music there are";
  final FirebaseAuth auth = FirebaseAuth.instance;
  String username = '';
  Room room;
  bool isInRoom = true;
  bool isLoading = false;
  List<Song> songs = [];
  Timer timer;
  Song song = new Song("00AA","Nothing Music there are","Ngô Văn Phát",1,"");
  SongDAO songDAO = new SongDAO();

  Future<List<Song>> getSongs() async {
    List<Song> allSongs = await songDAO.getAllSongs("VN");
    allSongs.addAll(await songDAO.getAllSongs("NN"));
    return allSongs;
  }

  Future<Song> getFirstSong(String songID) async {
    return await songDAO.getSongById(songID);
  }
  getUser() async {
    FirebaseUser user = await auth.currentUser();
    username = user.displayName;
  }

  Future<void> createRoom(String key) async {
    await getUser();
    room = new Room(key, musicName, username, '', '', '');
    room.updateToDatabase(key);
    saveAdditionalFields(roomId: key);
    savePreferences(userId: username, roomId: key, isHost: true);
    setState(() {
      isLoading = true;
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat();
    String key = randomString(6, from: 65, to: 90);
    createRoom(key);
    getFirstSong("01NN").then((val) {
      song = val;
      room.musicName=val.name;
    });
    getSongs().then((value) {
      songs = value;
    });

    // update additional fields: usernameOnePoints, usernameTwoPoints,...
    // for storing user points

    saveAdditionalFields(roomId: key);
    // write to preferences
    // for later retrieving in other screens
    savePreferences(userId: username, roomId: key, isHost: true);
    print('[create_room] done update database and save preferences');
    startTime();
  }

  Future<void> saveAdditionalFields({String roomId}) async {
    var ref = FirebaseDatabase.instance.reference().child('Room').child(roomId);
    ref.update({"usernameOnePoints": 0});
    ref.update({"usernameTwoPoints": 0});
    ref.update({"usernameThreePoints": 0});
    ref.update({"usernameFourPoints": 0});
  }

  Future<void> savePreferences(
      {String userId, String roomId, bool isHost}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
//    prefs.setString('userId', userId);
    prefs.setString(sharedPrefKeys.getRoomIdKey(), roomId);
    prefs.setBool(sharedPrefKeys.getIsRoomHostKey(), isHost);
  }

  @override
  void deactivate() {
    super.deactivate();
    _animationController.dispose();
    room.removeUserByName(username);
    timer.cancel();
  }

  backgroundFunction() {
    room.triggerReadFromDB(room.keyOfRoom);
    setState(() {
      this.isInRoom = true;
    });
  }

  startTime() {
    setState(() {
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        backgroundFunction();
      });
    });
  }

  onClickPlayButton(BuildContext context) {
    room.isPlaying = true;
    room.updateToDatabase(room.keyOfRoom);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => GamePlayOnline(song)));
  }

  onChooseMusic(String music) {
    setState(() {
      musicName = music;
    });
    room.musicName = music;
    room.updateToDatabase(room.keyOfRoom);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading == false
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SpinKitWave(
                  color: Colors.blue,
                  size: 50.0,
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: new AppBar(
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: const Color(0xff004466),
              title: new Text('WAITING ROOM'),
            ),
            backgroundColor: const Color(0xff004466),
            body: SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    Image.asset('assets/images/background.jpg',
                        fit: BoxFit.fill),
                    Container(
                        margin: EdgeInsets.only(top: 30),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.only(bottom: 50),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      'ROOM ID: ${room.keyOfRoom}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _animationController,
                                builder: (_, child) {
                                  return Transform.rotate(
                                    angle:
                                        _animationController.value * 1 * 3.14,
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
                                      '${room.musicName}',
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
                                      onPressed: () async {
                                        songs = await getSongs();
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Select song'),
                                                scrollable: true,
                                                content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Container(
                                                        height: 700.0,
                                                        width: 600.0,
                                                        child: ListView.builder(
                                                          itemCount:
                                                              songs.length,
                                                          itemBuilder:
                                                              (context, index) {
                                                            return GestureDetector(
                                                                onTap: () {
                                                                  onChooseMusic(
                                                                      songs[index]
                                                                          .getName());
                                                                  setState(() {
                                                                    song = songs[index];
                                                                  });
                                                                },
                                                                child: Card(
                                                                  child:
                                                                      ListTile(
                                                                    isThreeLine:
                                                                        true,
                                                                    leading:
                                                                        Container(
                                                                      height: double
                                                                          .infinity,
                                                                      child:
                                                                          ImageIcon(
                                                                        AssetImage(
                                                                            songs[index].getImage()),
                                                                        size:
                                                                            50,
                                                                        color: Color(
                                                                            0xFF3A5A98),
                                                                      ), //replaced by image if available
                                                                    ),
                                                                    title: Text(
                                                                        songs[index]
                                                                            .getName()),
                                                                    subtitle:
                                                                        Container(
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: <
                                                                            Widget>[
                                                                          Flexible(
                                                                            flex:
                                                                                3,
                                                                            child:
                                                                                Container(
                                                                              height: 30,
                                                                              child: new MarqueeWidget(
                                                                                text: songs[index].getArtists(),
                                                                                textStyle: new TextStyle(fontSize: 16.0),
                                                                                scrollAxis: Axis.horizontal,
                                                                              ),
                                                                              //Text(,overflow: TextOverflow.ellipsis,),
                                                                            ),
                                                                          ),
                                                                          Flexible(
                                                                            flex:
                                                                                3,
                                                                            child:
                                                                                SmoothStarRating(
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
                                                    ]),
                                              );
                                            });
                                      },
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 23),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    userInRoom(context, room.usernameOne),
                                    room.usernameTwo != ''
                                        ? userInRoom(context, room.usernameTwo)
                                        : GestureDetector(
                                            child: userInRoom(context, '+'),
                                            onTap: () {
                                              print("press add button");
                                            },
                                          ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    room.usernameThree != ''
                                        ? userInRoom(
                                            context, room.usernameThree)
                                        : GestureDetector(
                                            child: userInRoom(context, '+'),
                                            onTap: () {
                                              print("press add button");
                                            },
                                          ),
                                    room.usernameFour != ''
                                        ? userInRoom(context, room.usernameFour)
                                        : GestureDetector(
                                            child: userInRoom(context, '+'),
                                            onTap: () {
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
                                    onClickPlayButton(context);
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
            ),
          );
  }
}
