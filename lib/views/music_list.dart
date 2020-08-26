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

List<List<Song>> allSongs = new List.filled(3, []);
List<String> favorites = [];
bool _isVisible = true;
bool _isLoading = false;
bool _FavoritebtnEnabled = true;
bool loadedAll = false;
int gTabIndex = 0;
SongDAO songDAO = new SongDAO();

class MusicList extends StatefulWidget {
  @override
  _MusicListState createState() => _MusicListState();
}

class _MusicListState extends State<MusicList> {
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
        initialIndex: gTabIndex,
        child: Builder(builder: (BuildContext context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (!tabController.indexIsChanging) {
              loadedAll = false;
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
                                    Container(
                                        child: BodyLayout(
                                      tabIndex: 0,
                                      songs: allSongs[0],
                                    )),
                                    Container(
                                        child: BodyLayout(
                                            tabIndex: 1, songs: allSongs[1])),
                                    Container(
                                        child: BodyLayout(
                                            tabIndex: 2, songs: allSongs[2])),
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

class _BodyLayoutState extends State<BodyLayout> {
  List<Song> songs;
  List<int> listTracker = [-1, -1, -1];
  int expListCounter = 0;
  int selected = 0;
  int visileItems = 8;
  int tabIndex;
  final _scrollController = ScrollController();
  final GlobalKey datakey = GlobalKey();
  List<int> pageNumber = [0, 0, 0];
  List<int> itemsPerPage = [2, 2, 2];

  @override
  void initState() {
    songs = widget.songs;
    tabIndex = widget.tabIndex;
    gTabIndex = widget.tabIndex;
    getSongs(tabIndex).then((value) {
      setState(() {
        songs = value;
      });
    });
    super.initState();
    allSongs[tabIndex] = songs;
    addIntToSF("tabIndex", gTabIndex);
    _scrollController.addListener(() async {
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

    listTracker[0] = selected;
    fetchFavorites();
    expListCounter++;
  }

  @override
  Widget build(BuildContext context) {
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
      //applied to loaded songs
      for (int i = 0; i < allSongs[0].length; i++) {
        if (favorites.contains(allSongs[0][i].getId())) {
          allSongs[0][i].setFavorite(true);
          songDAO.updateSong(allSongs[0][i]);
        }
      }
      for (int i = 0; i < allSongs[1].length; i++) {
        if (favorites.contains(allSongs[1][i].getId())) {
          allSongs[1][i].setFavorite(true);
          songDAO.updateSong(allSongs[1][i]);
        }
      }

      //get list of unloaded songs
      for (String i in favorites) {
        bool isLoaded = true;
        songDAO.getSongById(i).then(
            (value) => value != null ? isLoaded = true : isLoaded = false);
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
          });
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
                .child(songs[selected].getId().padLeft(2, '0'))
                .update({"name": songs[selected].getName()});
          else if (tabIndex == 1)
            await db
                .child(songs[selected].getId().padLeft(2, '0'))
                .update({"name": songs[selected].getName()});
          //Không check cho tabindex 2 vì khi unfavorite sẽ xóa đó khỏi tab
          songs[selected].setFavorite(true);
          return !isLiked;
        } catch (e) {
          debugPrint("ERROR " + e.toString());
        }
      } else {
        try {
          var db =
              FirebaseDatabase.instance.reference().child("Favorites/" + uid);
          if (tabIndex == 0)
            await db.child(songs[selected].getId()).remove();
          else if (tabIndex == 1)
            await db.child(songs[selected].getId()).remove();
          songs[selected].setFavorite(false);
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

  Future<List> _fetchSongs(tabIndex, pageNum, pageSize) async {
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
                .startAt((pageNum * pageSize + 1).toString())
                .limitToFirst(pageSize)
                .once()
                .then((DataSnapshot snapshot) {
              Map<dynamic, dynamic> values = snapshot.value;
              values.forEach((key, values) {
                //songs.add(new Song(key, values["name"], values["artists"],values["difficulty"], values["image"],notes_dir: values["notes_dir"]));
                favorited_ids.add(key);
              });
            });
            List<String> tempFav = List.from(favorited_ids);
            List<String> localFav = await songDAO.getIdList("YT");
            List<String> notDownloaded =
                tempFav.toSet().difference(localFav.toSet()).toList();
          }
          if (songs.isEmpty) {
            loadedAll = true;
            _isVisible = false;
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
            });
          }
          else{
            debugPrint("Fetching from local");
          }allSongs[tabIndex]=songs;
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
            });
          }
          allSongs[tabIndex]=songs;
          if (counter == pageSize) pageNum++;
        } //Nhac Viet
        break;
    }
  }

  Future<List> _fetchSongById(String id) async {
    if (id.contains("VNDB")) {
      var db = FirebaseDatabase.instance
          .reference()
          .child("Songs/NhacViet/" + id.replaceAll("VNDB", ''));
      await db.once().then((DataSnapshot snapshot) {
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
        songs.add(temp);
      });
    } else if (id.contains("NNDB")) {
    } else if (!id.contains("DB")) {
      if (id.contains("VN")) {
      } else if (id.contains("NN")) {}
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
        musicList.addAll(await songDAO.getAllSongs("VN"));
      }
    });
    return allSongs[tabIndex] = musicList;
  } else if (tabIndex == 2) {
    List<Song> tmp = [];
    return allSongs[tabIndex] = tmp;
  }
  List<Song> tmp = [];
  return allSongs[tabIndex] = tmp;
}
