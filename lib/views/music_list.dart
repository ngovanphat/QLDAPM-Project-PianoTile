import 'dart:async';
import 'dart:core';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piano_tile/helper/local_db.dart';
import 'package:piano_tile/helper/shared_pref.dart';
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

/*
ID bài hát :
Nhạc việt : +VN
Nhạc Nước ngoài : +NN
Nhạc yêu thích: Không thay đổi id
Từ DB : +DB
vd :01VN, 01VNDB,...
*/




List<List<Song>> songs = new List.filled(3, []);
List<String> favorites = [];
bool _isVisible = true;
bool _isLoading = false;
bool _FavoritebtnEnabled = true;
bool loadedAll = false;
int tabIndex = 0;
SongDAO songDAO = new SongDAO();

class MusicList extends StatefulWidget {
  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
  @override
  void initState() {
    getIntValuesSF("tabIndex").then((value) {
      if (value != null) tabIndex = value;
    });
    super.initState();
  }

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
        initialIndex: tabIndex,
        child: Builder(builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              if (tabController.index == 2) {
                _fetchSongs(tabController.index, 0, 10);
              }
              loadedAll=false;
              _isLoading = false;
              _isVisible = true;
            }
          });
          return Scaffold(
              body: SafeArea(
                  top: false,
                  child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      child: Stack(fit: StackFit.passthrough, children: [
                        Image.asset('assets/images/background.jpg',
                            fit: BoxFit.cover),
                        RowOnTop(context, 0, 0),
                        Container(
                          margin: EdgeInsets.only(
                              top: displayHeight(context) * 0.08),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[

                              Expanded(
                                child: TabBarView(
                                  children: [
                                    Container(child: BodyLayout(tabIndex: 0)),
                                    Container(child: BodyLayout(tabIndex: 1)),
                                    Container(child: BodyLayout(tabIndex: 2)),
                                  ],
                                ),
                              ),
                              Container(
                                height: displayHeight(context) * 0.07,
                                child: Material(
                                  color: Color(0xff004466),
                                  child: TabBar(
                                    onTap: (index) {
                                      tabIndex = index;
                                      debugPrint(tabIndex.toString());
                                    },
                                    labelStyle: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                    indicatorColor: Colors.lightBlueAccent,
                                    indicatorWeight:
                                    displayHeight(context) * 0.01,
                                    labelColor: Colors.white,
                                    tabs: [
                                      Tab(
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            "Vietnamese",
                                            style: TextStyle(
                                              fontSize: displayHeight(context) *
                                                  0.022,
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
                                              fontSize: displayHeight(context) *
                                                  0.022,
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
                                              fontSize: displayHeight(context) *
                                                  0.022,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]))));
        }),
      ),
    );
  }
}

class BodyLayout extends StatefulWidget {
  final int tabIndex;
  BodyLayout({Key key, this.tabIndex}) : super(key: key);

  @override
  _BodyLayoutState createState() => _BodyLayoutState();
}

class _BodyLayoutState extends State<BodyLayout>
    with AutomaticKeepAliveClientMixin {
  List<int> listTracker = [-1, -1, -1];
  int expListCounter = 0;
  int selected = 0;
  int visileItems = 8;
  int tabIndex;
  final _scrollController = ScrollController();
  final GlobalKey datakey = GlobalKey();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    tabIndex = widget.tabIndex;
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
          debugPrint(songs[tabIndex].length.toString());
        });
      }
    });
    songs[tabIndex] = getSongs(tabIndex);
    listTracker[0] = selected;
    fetchFavorites();
    expListCounter++;
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
        padding: EdgeInsets.all(0),
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
      expansionCallback: (int index, bool isExpanded) {
        listTracker[expListCounter] = index;
        expListCounter++;
        if (isExpanded) {
          listTracker = [-1, -1, -1];
          expListCounter = 0;
          selected = -1;
          return;
        }
        if (expListCounter == 1) {
          selected = index;
        }
        if (expListCounter == 3) {
          expListCounter = 1;
          if (listTracker[0] == listTracker[2]) {
            selected = listTracker[1];
            int tmp = listTracker[1];
            listTracker = [tmp, -1, -1];
          } else {
            int tmp = listTracker[2];
            listTracker = [tmp, -1, -1];
            selected = tmp;
          }
        }
      },
      children: songs[this.tabIndex]
          .map<CustomExpansionPanel.ExpansionPanelRadio>((Song song) {
        return CustomExpansionPanel.ExpansionPanelRadio(
          value: songs[this.tabIndex].indexOf(song),
          canTapOnHeader: true,
          song: song,
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
                      isLiked: song.getFavorite() ? true : false,
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

  void fetchFavorites() async {
    if (favorites.isNotEmpty) return;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    if (user != null) {
      final uid = user.uid;
      var db =
          FirebaseDatabase.instance.reference().child('Favorites').child(uid);
      await db.once().then((DataSnapshot snapshot) {
        if (snapshot.value == null) return;
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          favorites.add(key);
        });
      });
      debugPrint(favorites.join(','));
      for (int i = 0; i < songs[tabIndex].length; i++) {
        if (favorites.contains(songs[tabIndex][i].getId())) {
          songs[tabIndex][i].setFavorite(true);
        }
      }
    }
  }

  Future<bool> onFavoriteButtonTapped(bool isLiked) async {
    debugPrint(_FavoritebtnEnabled.toString() + " , " + isLiked.toString());
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
          if (tabIndex == 0)
            await db
                .child(songs[tabIndex][selected].getId().padLeft(2, '0'))
                .update({"name": songs[tabIndex][selected].getName()});
          else if (tabIndex == 1)
            await db
                .child(songs[tabIndex][selected].getId().padLeft(2, '0'))
                .update({"name": songs[tabIndex][selected].getName()});
          //Không check cho tabindex 2 vì khi unfavorite sẽ xóa đó khỏi tab
          songs[tabIndex][selected].setFavorite(true);
          return !isLiked;
        } catch (e) {
          debugPrint("ERROR " + e.toString());
        }
      } else {
        try {
          var db =
              FirebaseDatabase.instance.reference().child("Favorites/" + uid);
          if (tabIndex == 0)
            await db.child(songs[tabIndex][selected].getId()).remove();
          else if (tabIndex == 1)
            await db.child(songs[tabIndex][selected].getId()).remove();
          songs[tabIndex][selected].setFavorite(false);
          return !isLiked;
        } catch (e) {
          debugPrint("ERROR " + e.toString());
        }
      }
    } else {
      Widget loginDialog = new LoginDialog();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return loginDialog;
        },
      );
    }
    return isLiked;
  }
//TODO refine id system for music list

}

Future<List> _fetchSongs(tabIndex, pageNumber, pageSize) async {
  switch (tabIndex) {
    case 2:
      {
        final FirebaseAuth auth = FirebaseAuth.instance;
        final FirebaseUser user = await auth.currentUser();
        if (user != null) {
          final uid = user.uid;
          List<String> favorited_ids = [];
          var db =
              FirebaseDatabase.instance.reference().child('Favorites/' + uid);
          await db
              .orderByKey()
              .startAt((pageNumber * 10 + 1).toString())
              .limitToFirst(10)
              .once()
              .then((DataSnapshot snapshot) {
            Map<dynamic, dynamic> values = snapshot.value;
            values.forEach((key, values) {
              //songs.add(new Song(key, values["name"], values["artists"],values["difficulty"], values["image"],notes_dir: values["notes_dir"]));
              favorited_ids.add(key);
            });
          });

        }
        if (songs[tabIndex].isEmpty) {
          loadedAll = true;
          _isVisible = false;
        }
      } //Yeu thich
      break;
    case 1:
      {
        var db =
            FirebaseDatabase.instance.reference().child("Songs/NhacNuocNgoai");
        await db
            .orderByKey()
            .startAt((pageNumber * 10 + 1).toString())
            .limitToFirst(10)
            .once()
            .then((DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          if(values==null){

          }
          values.forEach((key, values) {
            Song temp=new Song(key + "NNDB", values["name"],
                values["artists"], values["difficulty"], values["image"],
                notes_dir: values["notes_dir"]);
            songs[tabIndex].add(temp);
          });
        });
        pageNumber++;
      } //Nhac Nuoc Ngoai
      break;
    default:
      {
        var db = FirebaseDatabase.instance.reference().child("Songs/NhacViet");
        await db
            .orderByKey()
            .startAt((pageNumber * 10 + 1).toString())
            .limitToFirst(10)
            .once()
            .then((DataSnapshot snapshot) {
          Map<dynamic, dynamic> values = snapshot.value;
          values.forEach((key, values) {
            songs[tabIndex].add(new Song(key + "VNDB", values["name"],
                values["artists"], values["difficulty"], values["image"],
                notes_dir: values["notes_dir"]));
            Song temp=new Song(key + "NNDB", values["name"],
                values["artists"], values["difficulty"], values["image"],
                notes_dir: values["notes_dir"]);
            songs[tabIndex].add(temp);
          });
        });
      } //Nhac Viet
      break;
  }
}

List getSongs(tabIndex) {

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
  if (tabIndex == 1) {
    for (var i = titles.length - 1; i >= 0; i--) {
      musicList.add(new Song(i.toString().padLeft(2, '0') + "NN", titles[i],
          artists[i], difficulties[i], images[i],
          notes_dir:
              "https://firebasestorage.googleapis.com/v0/b/melody-tap.appspot.com/o/Shining_the_morning.mid.txt?alt=media&token=052c65bf-f531-40bc-9584-02f9cdb3f306"));
    }
  } else if (tabIndex == 0) {
    songDAO.isEmpty("VN").then((value) {
      if (value) {
        for (var i = 0; i < titles.length; i++) {
          musicList.add(new Song(i.toString().padLeft(2, '0') + "VN", titles[i],
              artists[i], difficulties[i], images[i],
              notes_dir:
                  "https://firebasestorage.googleapis.com/v0/b/melody-tap.appspot.com/o/Shining_the_morning.mid.txt?alt=media&token=052c65bf-f531-40bc-9584-02f9cdb3f306"));
        }
        for (var i = 0; i < musicList.length; i++) {
          songDAO.insertSong(musicList[i]);
        }
      } else {
        debugPrint("Reading from local");
        songDAO.getAllSongs("VN").then((value) => musicList.addAll(value));
      }
    });
  } else if (tabIndex == 2) {
    List<Song> tmp = [];
    return tmp;
  }
  return musicList;
}
