import 'dart:async';
import 'dart:core';

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
class Keys {
  static final tabVNKey = new GlobalKey<_BodyLayoutState>();
  static final tabNNKey = new GlobalKey<_BodyLayoutState>();
  static final tabYTKey = new GlobalKey<_BodyLayoutState>();
}

Map<int, GlobalKey> bodyKeys = {
  0: Keys.tabVNKey,
  1: Keys.tabNNKey,
  2: Keys.tabYTKey
};

List<List<Song>> allSongs = new List.filled(3, []);
List<String> favorites = [];
bool _isVisible = true;
bool _isLoading = false;
bool _FavoritebtnEnabled = true;
bool loadedAll = false;
int gTabIndex = 0;
SongDAO songDAO = new SongDAO();
Map newHighscores = Map<String, int>();

class MusicList extends StatefulWidget {
  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> with WidgetsBindingObserver {
  AppLifecycleState _lastLifecycleState;
  @override
  void initState() {
    /*allSongs[0].isEmpty?getSongs(0).then((value){
      setState(() {
      });
    // ignore: unnecessary_statements
    }):true;
    // ignore: unnecessary_statements
    allSongs[0].isEmpty?getSongs(1):true;*/
    getIntValuesSF("tabIndex").then((value) {
      if (value != null) gTabIndex = value;
    });
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        await updateAllHighscores();
        break;
      case AppLifecycleState.resumed:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
        initialIndex: gTabIndex,
        child: Builder(builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              loadedAll = false;
              /*if(tabController.index==2){
                getSongs(tabController.index).then((value){
                  bodyKeys[tabController.index].currentState.setState(() {
                  });
                });
              }*/
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
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    Container(
                                        child: BodyLayout(
                                          key: bodyKeys[0],
                                          tabIndex: 0,
                                          songs: allSongs[0],
                                        )),
                                    Container(
                                        child: BodyLayout(
                                            key: bodyKeys[1],
                                            tabIndex: 1,
                                            songs: allSongs[1])),
                                    Container(
                                        child: BodyLayout(
                                            key: bodyKeys[2],
                                            tabIndex: 2,
                                            songs: allSongs[2])),
                                  ],
                                ),
                              ),
                              Container(
                                height: displayHeight(context) * 0.07,
                                child: Material(
                                  color: Color(0xff004466),
                                  child: TabBar(
                                    onTap: (index) {
                                      gTabIndex = index;
                                      debugPrint(gTabIndex.toString());
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
                                                  0.021,
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
  final List<Song> songs;
  final int tabIndex;
  BodyLayout({Key key, this.tabIndex, this.songs}) : super(key: key);

  @override
  _BodyLayoutState createState() => _BodyLayoutState();
}

class _BodyLayoutState extends State<BodyLayout>
    with AutomaticKeepAliveClientMixin {
  List<Song> songs = [];
  List<int> listTracker = [-1, -1, -1];
  int expListCounter = 0;
  int selected = 0;
  int visileItems = 8;
  int tabIndex;
  final _scrollController = ScrollController();
  List<int> pageNumber = [0, 0, 0];
  List<int> itemsPerPage = [2, 2, 2];
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    songs = widget.songs;
    tabIndex = widget.tabIndex;
    gTabIndex = widget.tabIndex;
    if (tabIndex != 2) {
      getSongs(tabIndex).then((value) async {
        if (!mounted) return;
        setState((){
          songs = value;
          if (tabIndex == 1) {
            fetchHighscore();
            fetchFavorites();
          }
        });
      });
    } else {
      fetchFavorites().then((value) async {
        await _fetchSongs(tabIndex, pageNumber, itemsPerPage).then((value) {
          setState(() {
            songs = value ?? [];
          });
        });
      });
    }
    allSongs[tabIndex] = songs;
    addIntToSF("tabIndex", gTabIndex);
    _scrollController.addListener(() async {
      if(tabIndex==2)return;
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          _isLoading == false) {
        _isLoading = true;
        debugPrint('Page reached end of page');
        var loadedSongs = await _fetchSongs(
            tabIndex, pageNumber[tabIndex], itemsPerPage[tabIndex]);
        setState(() {
          //TODO show loading for repeated load
          //TODO save local after first download
          _isVisible = false;
          debugPrint(songs.length.toString());
        });
      }
    });
    int value = PageStorage.of(context).readState(context);
    if (value == null) {
      PageStorage.of(context).writeState(context, selected);
    } else {
      selected = value;
    }
    listTracker[0] = selected;
    expListCounter++;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return songs.isNotEmpty
        ? NotificationListener<OverscrollIndicatorNotification>(
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
          )
        : SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator()));
  }

  Widget _buildPanel() {
    return CustomExpansionPanel.ExpansionPanelList.radio(
      key: new PageStorageKey('tab' + tabIndex.toString()),
      initialOpenPanelValue: 0,
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
        debugPrint("Selected: " +
            selected.toString() +
            "- Song ID: " +
            songs[selected].getId());
      },
      children:
          songs.map<CustomExpansionPanel.ExpansionPanelRadio>((Song song) {
        return CustomExpansionPanel.ExpansionPanelRadio(
          value: songs.indexOf(song),
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
                          size: displayWidth(context) * 0.047,
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

  Future<List<Song>> fetchFavorites() async {
    debugPrint("favorites.isNotEmpty: " + favorites.isNotEmpty.toString());
    if (favorites.isNotEmpty) return songs;
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
      //applied to loaded songs
      for (int i = 0; i < allSongs[0].length; i++) {
        debugPrint("ID: " + allSongs[0][i].getId());
        if (favorites.contains(allSongs[0][i].getId())) {
          if (!allSongs[0][i].getFavorite()) {
            allSongs[0][i].setFavorite(true);
            songDAO.updateSong(allSongs[0][i]);
          }
          favorites.removeWhere((item) => item == allSongs[0][i].getId());
          debugPrint("After " + favorites.join(','));
        }
      }
      for (int i = 0; i < allSongs[1].length; i++) {
        debugPrint("ID: " + allSongs[1][i].getId());
        if (favorites.contains(allSongs[1][i].getId())) {
          if (!allSongs[1][i].getFavorite()) {
            allSongs[1][i].setFavorite(true);
            songDAO.updateSong(allSongs[1][i]);
          }
          favorites.removeWhere((item) => item == allSongs[1][i].getId());
          debugPrint("After " + favorites.join(','));
        }
      }

      if (favorites.isEmpty) {
        setState(() {
          songs = allSongs[tabIndex];
        });
      }
    }
    return songs;
  }

  Future<List<Song>> fetchHighscore() async {
    Map dbHighscores = Map<String, int>.from(newHighscores);
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseUser user = await auth.currentUser();
    if (user != null) {
      final uid = user.uid;
      var db =
          FirebaseDatabase.instance.reference().child('Highscores').child(uid);
      await db.once().then((DataSnapshot snapshot) {
        if (snapshot.value == null) return;
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, value) {
          dbHighscores[key]=value;
          debugPrint("highscore: "+key+" - "+value.toString());
        });
      });
      if (dbHighscores.isEmpty) return songs;
      //applied to loaded songs
      for (int i = 0; i < allSongs[0].length; i++) {
        //debugPrint("ID: "+allSongs[0][i].getId());
        if (dbHighscores.keys.contains(allSongs[0][i].getId())) {
          var thisKey =
              dbHighscores.keys.firstWhere((k) => k == allSongs[0][i].getId());
          var newScore = dbHighscores[thisKey];
          if (allSongs[0][i].getHighscore() < newScore) {
            allSongs[0][i].setHighscore(newScore);
            songDAO.updateSong(allSongs[0][i]);
          }
          dbHighscores.remove(allSongs[0][i].getId());
        }
      }
      for (int i = 0; i < allSongs[1].length; i++) {
        //debugPrint("ID: "+allSongs[1][i].getId());
        if (dbHighscores.keys.contains(allSongs[1][i].getId())) {
          var thisKey =
              dbHighscores.keys.firstWhere((k) => k == allSongs[1][i].getId());
          var newScore = dbHighscores[thisKey];
          if (allSongs[1][i].getHighscore() < newScore) {
            allSongs[1][i].setHighscore(newScore);
            songDAO.updateSong(allSongs[1][i]);
          }
          dbHighscores.remove(allSongs[1][i].getId());
        }
      }

      setState(() {
        songs = allSongs[tabIndex];
      });
    }
    return songs;
  }

  Future<bool> onFavoriteButtonTapped(bool isLiked) async {
    debugPrint("Selected: " +
        selected.toString() +
        "- Song ID: " +
        songs[selected].getId());
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
                .child(songs[selected].getId())
                .update({"name": songs[selected].getName()});
          else if (tabIndex == 1)
            await db
                .child(songs[selected].getId())
                .update({"name": songs[selected].getName()});
          //Không check cho tabindex 2 vì khi unfavorite sẽ xóa đó khỏi tab
          debugPrint("here 0");
          songs[selected].setFavorite(true);
          await songDAO.updateSong(songs[selected]);
          debugPrint("here");
          _BodyLayoutState caller =
              bodyKeys[2].currentState as _BodyLayoutState;
          if (caller != null)
            caller
                ._fetchSongs(
                    caller.tabIndex, caller.pageNumber, caller.itemsPerPage)
                .then((value) {
              caller.setState(() {
                caller.songs = value;
              });
            });

          debugPrint("here 3");
          return !isLiked;
        } catch (e) {
          debugPrint("ERROR " + e.toString());
        }
      } else {
        try {
          var db =
              FirebaseDatabase.instance.reference().child("Favorites/" + uid);
          await db.child(songs[selected].getId()).remove();
          songs[selected].setFavorite(false);
          await songDAO.updateSong(songs[selected]);
          if (tabIndex == 2) {
            //lưu lên db rồi xóa khỏi danh sách yêu thích & cập nhập 2 danh sách còn lại
            if (songs[selected].getId().contains("VN")) {
              allSongs[0][selected].setFavorite(false);
            } else if (songs[selected].getId().contains("NN")) {
              allSongs[1][selected].setFavorite(false);
            }
            setState(() {
              songs.removeAt(selected);
              _isVisible = false;
            });
            _BodyLayoutState tabNV = bodyKeys[0].currentState;
            _BodyLayoutState tabNN = bodyKeys[1].currentState;
            getSongs(0).then((value) {
              if (!tabNV.mounted) return;
              tabNV.setState(() {
                tabNV.songs = value;
              });
            });
            getSongs(1).then((value) {
              if (!tabNN.mounted) return;
              tabNN.setState(() {
                tabNN.songs = value;
              });
            });
          } else {
            _BodyLayoutState caller =
                bodyKeys[2].currentState as _BodyLayoutState;
            debugPrint("here 2");
            caller
                ._fetchSongs(
                    caller.tabIndex, caller.pageNumber, caller.itemsPerPage)
                .then((value) {
              caller.setState(() {
                caller.songs = value;
              });
            });
          }
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

  @override
  void dispose() {
    super.dispose();
  }

  // ignore: missing_return
  Future<List> _fetchSongs(tabIndex, pageNum, pageSize) async {
    switch (tabIndex) {
      case 2:
        {
          if (favorites.isNotEmpty) {
            //get list of unloaded songs
            for (String i in favorites) {
              bool isLoaded = true;
              await songDAO.getSongById(i).then((value) =>
                  value != null ? isLoaded = true : isLoaded = false);
              if (i.contains("NNDB") & !isLoaded) {
                var db = FirebaseDatabase.instance
                    .reference()
                    .child("Songs/NhacNuocNgoai/" + i.replaceAll("NNDB", ''));
                await db.once().then((DataSnapshot snapshot) {
                  Map<dynamic, dynamic> values = snapshot.value;
                  if (snapshot.value == null) {
                    debugPrint("Song not found");
                    return;
                  }
                  Song temp = new Song(
                      snapshot.key + "NNDB",
                      snapshot.value["name"],
                      snapshot.value["artists"],
                      snapshot.value["difficulty"],
                      snapshot.value["image"],
                      notes_dir: snapshot.value["notes_dir"],
                      isFavorited: true);
                  allSongs[1].add(temp);
                });
              } else if (i.contains("VNDB") & !isLoaded) {
                var db = FirebaseDatabase.instance
                    .reference()
                    .child("Songs/NhacViet/" + i.replaceAll("VNDB", ''));
                await db.once().then((DataSnapshot snapshot) {
                  Map<dynamic, dynamic> values = snapshot.value;
                  if (snapshot.value == null) {
                    debugPrint("Song not found");
                    return;
                  }
                  Song temp = new Song(
                      snapshot.key + "VNDB",
                      snapshot.value["name"],
                      snapshot.value["artists"],
                      snapshot.value["difficulty"],
                      snapshot.value["image"],
                      notes_dir: snapshot.value["notes_dir"],
                      isFavorited: true);
                  allSongs[1].add(temp);
                  favorites.removeWhere((item) => item == i);
                });
              }
            }
          }
          debugPrint("favorited list" + favorites.join('-'));
          debugPrint("favorited.isEmpty " + favorites.isEmpty.toString());
          if (favorites.isEmpty) {
            final List<Song> musicList = [];
            await musicList.addAll(await songDAO.getAllSongs("YT"));
            String dbug = "Yeu Thich";
            for (var item in musicList) {
              dbug += item.getId();
            }
            debugPrint(dbug);
            loadedAll = true;
            _isVisible = false;
            return allSongs[tabIndex] = musicList;
          }
        } //Yeu thich
        break;
      case 1:
        {
          int counter = 0;
          Song checkFirstOfPage;
          await songDAO
              .getSongById(
                  ((pageNum * pageSize + 1).toString().padLeft(2, '0') +
                      "NNDB"))
              .then((value) => checkFirstOfPage = value);
          if (checkFirstOfPage == null) {
            debugPrint("Fetching from firebase");
            var db = FirebaseDatabase.instance
                .reference()
                .child("Songs/NhacNuocNgoai");
            await db
                .orderByKey()
                .startAt((pageNum * pageSize + 1).toString())
                .limitToFirst(pageSize)
                .once()
                .then((DataSnapshot snapshot) {
              Map<dynamic, dynamic> values = snapshot.value;
              if (snapshot == null) {
                debugPrint("No more songs to load");
                return;
              }
              values.forEach((key, values) {
                Song temp = new Song(
                    key.padLeft(2, '0') + "NNDB",
                    values["name"],
                    values["artists"],
                    values["difficulty"],
                    values["image"],
                    notes_dir: values["notes_dir"]);
                songs.add(temp);
                songDAO.insertSong(temp);
                counter++;
              });
              setState(() {
                allSongs[tabIndex] = songs;
              });
            });
          } else {
            debugPrint("Fetching from local");
            /* for(int i=0;i<pageSize;i++){
              Song temp;
              await songDAO
                  .getSongById(
                  ((pageNum * pageSize + 1).toString().padLeft(2, '0') +
                      "NNDB"))
                  .then((value) => temp = value);
              if(temp==null){
                break;
              }else{

              }
            }*/
          }
          if (counter == pageSize) pageNum++;
        } //Nhac Nuoc Ngoai
        break;
      default:
        {
          int counter = 0;
          Song checkFirstOfPage = await songDAO.getSongById(
              (pageNum * pageSize + 1).toString().padLeft(2, '0') + "VNDB");
          if (checkFirstOfPage == null) {
            var db =
                FirebaseDatabase.instance.reference().child("Songs/NhacViet");
            await db
                .orderByKey()
                .startAt((pageNum * pageSize + 1).toString())
                .limitToFirst(pageSize)
                .once()
                .then((DataSnapshot snapshot) {
              Map<dynamic, dynamic> values = snapshot.value;
              values.forEach((key, values) {
                Song temp = new Song(
                    key.padLeft(2, '0') + "VNDB",
                    values["name"],
                    values["artists"],
                    values["difficulty"],
                    values["image"],
                    notes_dir: values["notes_dir"]);
                songs.add(temp);
                songDAO.insertSong(temp);
                counter++;
              });
              setState(() {
                allSongs[tabIndex] = songs;
              });
            });
          }
          allSongs[tabIndex] = songs;
          if (counter == pageSize) pageNum++;
        } //Nhac Viet
        break;
    }
  }
}
//TODO refine id system for music list

Future<List> getSongs(tabIndex) async {
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

  if (tabIndex == 1) {
    final List<Song> musicList = [];
    await songDAO.isEmpty("NN").then((value) async {
      if (value) {
        for (var i = titles.length - 1; i >= 0; i--) {
          musicList.add(new Song(i.toString().padLeft(2, '0') + "NN", titles[i],
              artists[i], difficulties[i], images[i],
              notes_dir:
                  "https://firebasestorage.googleapis.com/v0/b/melody-tap.appspot.com/o/Shining_the_morning.mid.txt?alt=media&token=052c65bf-f531-40bc-9584-02f9cdb3f306"));
        }
        for (var i = 0; i < musicList.length; i++) {
          songDAO.insertSong(musicList[i]);
        }
      } else {
        debugPrint("Reading from local ");
        songDAO
            .countSongs("NN")
            .then((value) => debugPrint("Count : " + value.toString()));
        musicList.addAll(await songDAO.getAllSongs("NN"));
      }
    });
    return allSongs[tabIndex] = musicList;
  } else if (tabIndex == 0) {
    final List<Song> musicList = [];
    await songDAO.isEmpty("VN").then((value) async {
      if (value) {
        for (var i = 0; i < titles.length; i++) {
          musicList.add(new Song(i.toString().padLeft(2, '0') + "VN", titles[i],
              artists[i], difficulties[i], images[i],
              notes_dir:
                  "https://firebasestorage.googleapis.com/v0/b/melody-tap.appspot.com/o/canond.mid.txt?alt=media&token=0d3fbea0-61be-4e9e-832e-dcec4bf16727"));
        }
        for (var i = 0; i < musicList.length; i++) {
          songDAO.insertSong(musicList[i]);
        }
      } else {
        debugPrint("Reading from local ");
        songDAO
            .countSongs("NN")
            .then((value) => debugPrint("Count : " + value.toString()));
        musicList.addAll(await songDAO.getAllSongs("VN"));
      }
    });
    return allSongs[tabIndex] = musicList;
  } else if (tabIndex == 2) {
    final List<Song> musicList = [];
    musicList.addAll(await songDAO.getAllSongs("YT"));
    String dbug = "Yeu Thich";
    for (var item in musicList) {
      dbug += item.getId();
    }
    debugPrint(dbug);
    return allSongs[tabIndex] = musicList;
  }
  List<Song> tmp = [];
  return allSongs[tabIndex] = tmp;
}

Future<int> updateAllHighscores() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseUser user = await auth.currentUser();
  if (user != null) {
    final uid = user.uid;
    var db =
        FirebaseDatabase.instance.reference().child('Highscores').child(uid);
    List<Song> updatingSongs = await songDAO.getAllSongs("Highscore");
    var localHighscores = Map.fromIterable(updatingSongs,
        key: (s) => s.getId(), value: (s) => s.getHighscore());
    newHighscores.removeWhere(
        (key, value) => newHighscores[key] == localHighscores[key]);
    newHighscores.updateAll((key, value) =>
        newHighscores[key] < localHighscores[key]
            ? value = localHighscores[key]
            : value = newHighscores[key]);
    newHighscores.forEach((key, value) async {
      await db.child(key).update(value);
    });
    return 0;
  }
  return 1;
}
