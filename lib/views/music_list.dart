import 'dart:core';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piano_tile/model/Song.dart';
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
              preferredSize: Size.fromHeight(130.0), // here the desired height
              child: AppBar(
                // bỏ comment để hiện thanh tài nguyên trên cùng màn hình
                title: RowOnTop(context, 0, 0),
                bottom: TabBar(
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                  indicatorColor: Colors.white12,
                  indicatorWeight: 10.0,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text("Vietnamese",
                        style: TextStyle(
                          fontSize: 18,
                        ),),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Foreign",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    Tab(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Favorited",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
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
                            image: AssetImage('assets/images/background.jpg'), fit: BoxFit.cover)
                    ),
                    child:BodyLayout(1)),
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/background.jpg'), fit: BoxFit.cover)
                    ),
                    child:BodyLayout(2)),
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
  BodyLayout(int tabIndex){
    this.tabIndex=tabIndex;
  }

  @override
  _BodyLayoutState createState() => _BodyLayoutState(tabIndex);
}

class _BodyLayoutState extends State<BodyLayout> {
  int tabIndex;
  //danh sách bài hát
  List<Song> songs=[];
  int selected = -1; //attention
  int visileItems=8;
  final scrollController = ScrollController();
  double cardHeight=70;
  final GlobalKey datakey=GlobalKey();
  _BodyLayoutState(tabIndex){
    this.tabIndex=tabIndex;

  }

  @override
  void initState() {
    songs= getSongs(tabIndex);
  }

 /* @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(// tắt hiệu ứng glow khi cuộn tới cuối list/ đầu list
      onNotification: (OverscrollIndicatorNotification overscroll) {
        overscroll.disallowGlow(); return true;
      },
      child: ListView.builder(
        *//*key: Key('builder ${selected.toString()}'),*//*
        key:datakey,
        controller: scrollController,
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () {
                final snackBar = SnackBar(content: Text(songs[index].getName()));//phát bài nhạc để nghe thử khi nhấn vào/show thành tích
                Scaffold.of(context).showSnackBar(snackBar);
              },
              child:Card(
                child: ExpansionTile(
                  //isThreeLine: true,
                  key: Key(index.toString()), //attention
                  initiallyExpanded : index==selected, //attention
                  onExpansionChanged: ((newState){
                    if(newState)
                      setState(() {
                        Duration(seconds:  20000);
                        selected = index;
                      });
                    else setState(() {
                      selected = -1;
                    });
                  }),
                  leading:Container(
                    height: double.infinity,
                    child:ImageIcon(
                      AssetImage('assets/images/music-note.png'),
                      size: 50,
                      color: Color(0xFF3A5A98),
                    ),//replaced by image if available
                  ),
                  title: Text(songs[index].getName()),
                  subtitle:  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          flex:3,
                          child:Container(
                            height: 30,
                            child: MarqueeWidget(
                              text:songs[index].getArtists().join('-'),
                              textStyle: TextStyle(fontSize: 16.0),
                              scrollAxis: Axis.horizontal,),
                            //Text(,overflow: TextOverflow.ellipsis,),
                          ),),
                        Flexible(
                          flex: 3,
                          child:SmoothStarRating(
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
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Flexible(
                          flex:5,
                          child:Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal:15.0),
                            child: Text('Thành tích : '+songs[index].getHighscore().toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,fontSize: 17,color: Colors.lightBlue[900].withOpacity(0.8)
                                ))
                            //Text(,overflow: TextOverflow.ellipsis,),
                          ),),
                        Flexible(
                          flex: 2,
                          child:LikeButton(
                            size:50,
                            bubblesSize: 50,
                            circleSize: 30,
                            circleColor: CircleColor(start: Colors.amber, end: Colors.redAccent),
                            bubblesColor: BubblesColor(
                              dotPrimaryColor: Colors.redAccent,
                              dotSecondaryColor: Colors.amber,
                            ),
                            likeBuilder: (bool isLiked) {
                              return Icon(
                                Icons.favorite,
                                color: isLiked ? Colors.redAccent : Colors.grey,
                                size: 30,
                              );
                            },
                          )
                        )
                      ],
                    ),
                  ],
                  trailing:  RaisedButton(
                    color: Colors.amber,
                    child: Text("Chơi"),
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                    onPressed: () => {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => Home())
                      )},
                  ),
                ),
              )
          );
        },
      ),);
  }*/
  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(// tắt hiệu ứng glow khi cuộn tới cuối list/ đầu list
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowGlow(); return true;
        },
        child: ListView(
          children: <Widget>[
            Container(
              child: _buildPanel(),
            ),
          ],
        ),
    );
  }
  Widget _buildPanel() {
    return ExpansionPanelList.radio(
      initialOpenPanelValue: 2,
      children: songs.map<ExpansionPanelRadio>((Song song) {
        return ExpansionPanelRadio(
            value: song.id,
            canTapOnHeader: true,
            headerBuilder: (BuildContext context, bool isExpanded) {//Header
              return ListTile(
                leading:Container(
                  height: double.infinity,
                  child:ImageIcon(
                    AssetImage('assets/images/music-note.png'),
                    size: 50,
                    color: Color(0xFF3A5A98),
                  ),//replaced by image if available
                ),
                title: Text(song.getName()),
                subtitle:  Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        flex:3,
                        child:Container(
                          height: 30,
                          child: MarqueeWidget(
                            text:song.getArtists().join('-'),
                            textStyle: TextStyle(fontSize: 16.0),
                            scrollAxis: Axis.horizontal,),
                          //Text(,overflow: TextOverflow.ellipsis,),
                        ),),
                      Flexible(
                        flex: 3,
                        child:SmoothStarRating(
                          rating: song.getDifficulty().toDouble(),
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
              );
            },
            body: ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Flexible(
                      flex:5,
                      child:Container(
                          height: 30,
                          padding: EdgeInsets.symmetric(horizontal:15.0),
                          child: Text('Highscore : '+song.getHighscore().toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,fontSize: 17,color: Colors.lightBlue[900].withOpacity(0.8)
                              ))
                        //Text(,overflow: TextOverflow.ellipsis,),
                      ),),
                    Flexible(
                        flex: 2,
                        child:LikeButton(
                          size:50,
                          bubblesSize: 50,
                          circleSize: 30,
                          circleColor: CircleColor(start: Colors.amber, end: Colors.redAccent),
                          bubblesColor: BubblesColor(
                            dotPrimaryColor: Colors.redAccent,
                            dotSecondaryColor: Colors.amber,
                          ),
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              Icons.favorite,
                              color: isLiked ? Colors.redAccent : Colors.grey,
                              size: 30,
                            );
                          },
                        )
                    )
                  ],
                ),
            trailing: RaisedButton(
              color: Colors.amber,
              child: Text("Play"),
              shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
              onPressed: () => {
                Navigator.push(context,MaterialPageRoute(builder: (context) => GamePlay())
                )},
            ),
            ),);
      }).toList(),
    );
  }
}

class BottomNavLayout extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return bottomNav(context);
  }
}

Widget songsListView(BuildContext context, tabIndex) {
  //tên bài hát
  List<Song> songs = getSongs(tabIndex);

  return NotificationListener<OverscrollIndicatorNotification>(// tắt hiệu ứng glow khi cuộn tới cuối list/ đầu list
    onNotification: (OverscrollIndicatorNotification overscroll) {
      overscroll.disallowGlow();
      return true;
    },
    child: ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              final snackBar = SnackBar(
                  content: Text(songs[index]
                      .getName())); //phát bài nhạc để nghe thử khi nhấn vào/show thành tích
              Scaffold.of(context).showSnackBar(snackBar);
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
                trailing: RaisedButton(
                  color: Colors.amber,
                  child: Text("Chơi"),
                  shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0)),
                  onPressed: () => {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => GamePlay()))
                  },
                ),
              ),
            ));
      },
    ),
  );
}

Widget bottomNav(BuildContext context) {
  return BottomNavigationBar(
    selectedItemColor: Colors.white,
    backgroundColor: Colors.lightBlue[900],
    currentIndex: 1, // this will be set when a new tab is tapped
    items: [
      BottomNavigationBarItem(
        icon: new Icon(Icons.home),
        title: new Text('Home',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      BottomNavigationBarItem(
        icon: new Icon(Icons.library_music),
        title: new Text('Songs',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text('Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)))
    ],
  );
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
        i.toString(), titles[i], [artists[i]], difficulties[i], images[i]));
  }
  if(tabIndex==1) {
    return musicList.reversed.toList();
  }else if(tabIndex==2){
    musicList.removeRange(4, 8);
    return musicList;
  }
  else return musicList;
}
