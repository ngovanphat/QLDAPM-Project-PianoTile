import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'package:piano_tile/helper/local_db.dart';
import 'package:piano_tile/model/Song.dart';
import 'package:piano_tile/model/widget.dart';
import 'package:piano_tile/views/game_play.dart';
import 'package:piano_tile/views/game_play_online.dart';
import 'package:piano_tile/views/logged_in_profile.dart';
import 'package:piano_tile/views/profile.dart';
import 'package:piano_tile/views/music_list.dart';
import 'package:piano_tile/views/create_room.dart';
import 'package:piano_tile/model/ad_manager.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:piano_tile/model/room.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piano_tile/helper/sharedPreferencesDefinition.dart';
import 'package:piano_tile/main.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>
    with SingleTickerProviderStateMixin, RouteAware {
  AnimationController _animationController;
  int _currentIndex = 0;
  TextEditingController roomKeyInput = new TextEditingController();

  // exp, gem, level
  int currentExp = 0;
  int nextExp = 0;
  int gem = 0;
  int level = 1;
  String musicName = "Little Star";
  List<Song> songs = [];
  SongDAO songDAO = new SongDAO();

  Future<List<Song>> getSongs() async {
    List<Song> allSongs = await songDAO.getAllSongs("VN");
    allSongs.addAll(await songDAO.getAllSongs("NN"));
    return allSongs;
  }

  FirebaseUser user;
  Future<void> getUser() async {
    user = await FirebaseAuth.instance.currentUser();
  }

  Future<void> _initAdMob() {
    // TODO: Initialize AdMob SDK
    return FirebaseAdMob.instance.initialize(appId: AdManager.appId);
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 1))
          ..repeat();

    getUser();

    // update exp, gem,...
    getExpGem();
    getSongs().then((value){
      songs = value;
    });
  }

  Future<String> getExpGem() async {
    // get exp, next exp, gem from local file
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // set states
    setState(() {
      this.currentExp = prefs.getInt(sharedPrefKeys.getExpKey());
      this.nextExp = prefs.getInt(sharedPrefKeys.getNextExpKey());
      this.gem = prefs.getInt(sharedPrefKeys.getGemKey());
      this.level = prefs.getInt(sharedPrefKeys.getLevelKey());
    });

    return 'done';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context));
  }

  @override
  void didPush() {
    // Route was pushed onto navigator and is now topmost route.
    // update exp, gem,...
    getExpGem();
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
    // update exp, gem,...
    getExpGem();
  }

  @override
  dispose() {
    _animationController.dispose(); // you need this
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff004466),
      body: SafeArea(
        top: true,
        child: IndexedStack(index: _currentIndex, children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
                RowOnTop_v2(context, this.level, this.gem, this.currentExp,
                    this.nextExp),
                Container(
                    margin: EdgeInsets.only(top: 100),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
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
                                    onPressed: () async {
                                      songs =  await getSongs();
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
                                                        itemCount: songs.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  musicName = songs[index].getName();
                                                                });
                                                                Navigator.of(
                                                                    context)
                                                                    .pop();
                                                              },
                                                              child: Card(
                                                                child: ListTile(
                                                                  isThreeLine:
                                                                  true,
                                                                  leading:
                                                                  Container(
                                                                    height: double
                                                                        .infinity,
                                                                    child:
                                                                    ImageIcon(
                                                                      AssetImage(
                                                                          songs[index]
                                                                              .getImage()),
                                                                      size: 50,
                                                                      color: Color(
                                                                          0xFF3A5A98),
                                                                    ), //replaced by image if available
                                                                  ),
                                                                  title: Text(songs[
                                                                  index]
                                                                      .getName()),
                                                                  subtitle:
                                                                  Container(
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                      children: <
                                                                          Widget>[
                                                                        Flexible(
                                                                          flex:
                                                                          3,
                                                                          child:
                                                                          Container(
                                                                            height:
                                                                            30,
                                                                            child:
                                                                            new MarqueeWidget(
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
                                                                            rating:
                                                                            songs[index].getDifficulty().toDouble(),
                                                                            size:
                                                                            18,
                                                                            filledIconData:
                                                                            Icons.music_note,
                                                                            defaultIconData:
                                                                            null,
                                                                            starCount:
                                                                            5,
                                                                            isReadOnly:
                                                                            true,
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
                              width: 350,
                              height: 55,
                              margin: EdgeInsets.only(top: 20),
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GamePlay()));
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
                            ),
                            Container(
                              width: 350,
                              height: 55,
                              margin: EdgeInsets.only(top: 20),
                              child: FlatButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Container(
                                      // Aligns the container to center
                                      child: FractionallySizedBox(
                                        heightFactor: 1,
                                        widthFactor: 0.80,
                                        child: Center(
                                          child: new Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                new FlatButton(
                                                    color: Colors.blue[900],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        70),
                                                            side:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 3)),
                                                    child: Container(
                                                      height: 50,
                                                      child: new Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right: 8.0),
                                                            child: Icon(
                                                                Icons
                                                                    .add_circle_outline,
                                                                color: Colors
                                                                    .white,
                                                                size: 30),
                                                          ),
                                                          Text(
                                                            "Create room",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 25),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      if (user == null) {
                                                        customAlertDialog(
                                                            context,
                                                            'Please login');
                                                      } else {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CreateRoom()));
                                                      }
                                                    }),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 30)),
                                                new FlatButton(
                                                    color: Colors.blue[900],
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        70),
                                                            side:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white,
                                                                    width: 3)),
                                                    child: Container(
                                                      height: 50,
                                                      child: new Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    right:
                                                                        14.0),
                                                            child: new Icon(
                                                                Icons
                                                                    .exit_to_app,
                                                                color: Colors
                                                                    .white,
                                                                size: 30),
                                                          ),
                                                          new Text(
                                                            "Join room",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 25),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            Material(
                                                          type: MaterialType
                                                              .transparency,
                                                          child:
                                                              FractionallySizedBox(
                                                            heightFactor: 0.3,
                                                            widthFactor: 0.80,
                                                            child: Container(
                                                              padding:
                                                                  new EdgeInsets
                                                                          .all(
                                                                      25.0),
                                                              decoration:
                                                                  new BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20),
                                                              ),
                                                              child: Center(
                                                                child:
                                                                    new Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: <
                                                                      Widget>[
                                                                    new TextField(
                                                                      controller:
                                                                          roomKeyInput,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .text,
                                                                      decoration:
                                                                          new InputDecoration(
                                                                              hintText: "Enter room code"),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              25),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                              .only(
                                                                          top:
                                                                              40),
                                                                    ),
                                                                    FlatButton(
                                                                      color: Colors
                                                                          .blueAccent,
                                                                      child:
                                                                          new Text(
                                                                        "Join",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                25),
                                                                      ),
                                                                      onPressed:
                                                                          () async {
                                                                        if (user ==
                                                                            null) {
                                                                          customAlertDialog(
                                                                              context,
                                                                              'Please login');
                                                                        } else {
                                                                          Room.joinRoom(
                                                                              context,
                                                                              '${user.displayName}',
                                                                              roomKeyInput.text);
                                                                        }
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(
                                                                              70),
                                                                          side: BorderSide(
                                                                              color: Colors.white,
                                                                              width: 3)),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ]),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(70),
                                    side: BorderSide(
                                        color: Colors.white, width: 3)),
                                child: Text(
                                  'Multiplay',
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.white),
                                ),
                                color: Colors.white24,
                              ),
                            )
                          ]),
                    ))
              ],
            ),
          ),
          MusicList(),
          Profile(),
        ]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: allDestinations.map((Destination destination) {
          return BottomNavigationBarItem(
              icon: Icon(destination.icon), title: Text(destination.title));
        }).toList(),
        iconSize: 32,
        selectedItemColor: Colors.white,
        backgroundColor: const Color(0xff004466),
      ),
    );
  }
}

class Destination {
  const Destination(this.title, this.icon);
  final String title;
  final IconData icon;
}

const List<Destination> allDestinations = <Destination>[
  Destination('Home', Icons.home),
  Destination('Songs', Icons.music_note),
  Destination('Profile', Icons.person),
];
