import 'dart:async';
import 'dart:core';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piano_tile/helper/sizes_helpers.dart';
import 'package:piano_tile/model/Song.dart';
import 'package:piano_tile/model/custom_expansion_panel.dart'
    as CustomExpansionPanel;
import 'package:piano_tile/model/login_alert_dialog.dart';
import 'package:piano_tile/views/home.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:marquee_flutter/marquee_flutter.dart';
import 'package:piano_tile/model/widget.dart';
import 'package:like_button/like_button.dart';

import 'game_play.dart';

class MusicList extends StatefulWidget {
  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return NotificationListener<OverscrollIndicatorNotification>(
      // để che hiệu ứng glow khi cuộn ở 2 đầu
      onNotification: (OverscrollIndicatorNotification overscroll) {
        overscroll.disallowGlow();
        return true;
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Color(0xFF373737),
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(displayHeight(context) * 0.15),
            child: AppBar(
              automaticallyImplyLeading: false, //Xóa dấu back
              centerTitle:
                  true, //Cho 2 mục trong title căn giữa - vẫn hơi lệch 1 chút so với Home
              title: RowOnTop(context, 0, 0),
              bottom: TabBar(
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
                indicatorColor: Colors.white12,
                indicatorWeight: displayHeight(context) * 0.01,
                labelColor: Colors.white,
                tabs: [
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Vietnamese",
                        style: TextStyle(
                          fontSize: displayHeight(context) * 0.022,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Foreign",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: displayHeight(context) * 0.022,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Favorite",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: displayHeight(context) * 0.022,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.jpg'),
                          fit: BoxFit.cover)),
                  child: BodyLayout(0)),
              Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.jpg'),
                          fit: BoxFit.cover)),
                  child: BodyLayout(1)),
              Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/background.jpg'),
                          fit: BoxFit.cover)),
                  child: BodyLayout(2)),
            ],
          ),
        ),
      ),
    );
  }
}

class BodyLayout extends StatefulWidget {
  int tabIndex;
  //BodyLayout({Key key, this.tabIndex}) : super(key: key);
  BodyLayout(int tabIndex) {
    this.tabIndex = tabIndex;
  }

  @override
  _BodyLayoutState createState() => _BodyLayoutState(tabIndex);
}

class _BodyLayoutState extends State<BodyLayout> {
  int tabIndex;
  //danh sách bài hát
  List<Song> songs = [];
  int selected = 0;
  int visileItems = 8;
  bool _isVisible = true;
  bool _isLoading = false;
  bool _FavoritebtnEnabled = true;
  final _scrollController = ScrollController();
  final GlobalKey datakey = GlobalKey();
  _BodyLayoutState(tabIndex) {
    this.tabIndex = tabIndex;
  }

  @override
  void initState() {
    songs = getSongs(tabIndex);
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _isLoading == false) {
        _isLoading = true;
        debugPrint('Page reached end of page');
        var loadedSongs = await _fetchSongs(tabIndex, 0, 10);
        setState(() {
          //TODO show loading for repeated load
          //TODO save local after first download
          _isVisible = false;
          debugPrint(songs.length.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
      // tắt hiệu ứng glow khi cuộn tới cuối list/ đầu list
      onNotification: (t) {
        if (t is OverscrollIndicatorNotification) {
          t.disallowGlow();
        }
        return true;
      },
      child: ListView(
        controller: _scrollController,
        children: <Widget>[
          Container(
            child: _buildPanel(),
          ),
          Visibility(
            visible: _isVisible,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.1,
              child: Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPanel() {
    return CustomExpansionPanel.ExpansionPanelList.radio(
      initialOpenPanelValue: selected,
      expansionCallback: (int index, bool isExpanded) {
        if (isExpanded) selected = index;
      },
      children:
          songs.map<CustomExpansionPanel.ExpansionPanelRadio>((Song song) {
        return CustomExpansionPanel.ExpansionPanelRadio(
          value: songs.indexOf(song),
          canTapOnHeader: true,
          song :song,
          headerBuilder: (BuildContext context, bool isExpanded) {
            //Header
            return Container(
              height: displayHeight(context) * 0.12,
              alignment: Alignment.center,
              child: ListTile(
                leading: Container(
                  height: double.infinity,
                  child: ImageIcon(
                    AssetImage('assets/images/music-note.png'),
                    size: displayHeight(context) * 0.06,
                    color: Color(0xFF3A5A98),
                  ), //replaced by image if available
                ),
                title: Text(song.getName(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: displayWidth(context) * 0.045,
                    )),
                subtitle: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        flex: 3,
                        child: Container(
                          height: displayHeight(context) * 0.037,
                          child: MarqueeWidget(
                            text: song.getArtists(),
                            textStyle: TextStyle(
                                fontSize: displayWidth(context) * 0.04),
                            scrollAxis: Axis.horizontal,
                          ),
                          //Text(,overflow: TextOverflow.ellipsis,),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: SmoothStarRating(
                          rating: song.getDifficulty().toDouble(),
                          size: displayWidth(context) * 0.05,
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
            );
          },
          body: ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Flexible(
                  flex: 5,
                  child: Container(
                      height: displayWidth(context) * 0.113,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(
                          horizontal: displayHeight(context) * 0.02),
                      child: Text(
                          'Highscore : ' + song.getHighscore().toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: displayWidth(context) * 0.045,
                              color: Colors.lightBlue[900].withOpacity(0.8)))
                      //Text(,overflow: TextOverflow.ellipsis,),
                      ),
                ),
                Flexible(
                    flex: 1,
                    child: LikeButton(
                      onTap: onFavoriteButtonTapped,
                      size: displayHeight(context) * 0.060,
                      bubblesSize: displayHeight(context) * 0.06,
                      circleSize: displayHeight(context) * 0.037,
                      circleColor: CircleColor(
                          start: Colors.amber, end: Colors.redAccent),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: Colors.redAccent,
                        dotSecondaryColor: Colors.amber,
                      ),
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          Icons.favorite,
                          color: isLiked ? Colors.redAccent : Colors.grey,
                          size: displayHeight(context) * 0.04,
                        );
                      },
                    ))
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<bool> onFavoriteButtonTapped(bool isLiked) async {
    //TODO test this func after login finish
    debugPrint(_FavoritebtnEnabled.toString());
    if (_FavoritebtnEnabled == false) return isLiked;
    _FavoritebtnEnabled = false;
    Timer(Duration(seconds: 2), () => _FavoritebtnEnabled = true);

    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    if (user != null) {
      final uid = user.uid;
      if (!isLiked) {
        try {
          var db =
              FirebaseDatabase.instance.reference().child("Favorites/" + uid);
          await db.update({songs[selected].getId(): songs[selected].getName()});

          return !isLiked;
        } catch (e) {
          debugPrint(e.toString());
        }
      } else {
        try {
          var db =
              FirebaseDatabase.instance.reference().child("Favorites/" + uid);
          await db.child(songs[selected].getId()).remove();
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }else{
      Widget loginDialog=new LoginDialog();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return loginDialog;
        },
      );
    }
    return isLiked;
  }

  Future<List> _fetchSongs(tabIndex, pageNumber, pageSize) async {
    switch (tabIndex) {
      case 2:
        {
          final FirebaseAuth auth = FirebaseAuth.instance;
          final FirebaseUser user = await auth.currentUser();
          final uid = user.uid;
          var db =
              FirebaseDatabase.instance.reference().child("Favorites/" + uid);
          await db
              .orderByKey()
              .startAt((pageNumber * 10 + 1).toString())
              .limitToFirst(10)
              .once()
              .then((DataSnapshot snapshot) {
            Map<dynamic, dynamic> values = snapshot.value;
            values.forEach((key, values) {
              songs.add(new Song(key, values["name"], values["artists"],
                  values["difficulty"], values["image"],notes_dir: values["notes_dir"]));
            });
          });
        } //Yeu thich
        break;
      case 1:
        {
          var db = FirebaseDatabase.instance
              .reference()
              .child("Songs/NhacNuocNgoai");
          await db
              .orderByKey()
              .startAt((pageNumber * 10 + 1).toString())
              .limitToFirst(10)
              .once()
              .then((DataSnapshot snapshot) {
            Map<dynamic, dynamic> values = snapshot.value;
            values.forEach((key, values) {
              songs.add(new Song(key + "NN", values["name"], values["artists"],
                  values["difficulty"], values["image"],notes_dir: values["notes_dir"]));
            });
          });
        } //Nhac Nuoc Ngoai
        break;
      default:
        {
          var db =
              FirebaseDatabase.instance.reference().child("Songs/NhacViet");
          await db
              .orderByKey()
              .startAt((pageNumber * 10 + 1).toString())
              .limitToFirst(10)
              .once()
              .then((DataSnapshot snapshot) {
            Map<dynamic, dynamic> values = snapshot.value;
            values.forEach((key, values) {
              songs.add(new Song(key + "NN", values["name"], values["artists"],
                  values["difficulty"], values["image"],notes_dir: values["notes_dir"]));
            });
          });
        } //Nhac Viet
        break;
    }
  }
}

List getSongs(tabIndex) {
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
        i.toString(), titles[i], artists[i], difficulties[i], images[i], notes_dir: "https://firebasestorage.googleapis.com/v0/b/melody-tap.appspot.com/o/Shining_the_morning.mid.txt?alt=media&token=052c65bf-f531-40bc-9584-02f9cdb3f306"));
  }
  if (tabIndex == 1) {
    return musicList.reversed.toList();
  } else if (tabIndex == 2) {
    musicList.removeRange(4, 8);
    return musicList;
  } else
    return musicList;
}
