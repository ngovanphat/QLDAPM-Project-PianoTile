import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piano_tile/views/home.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:marquee_flutter/marquee_flutter.dart';

class MusicList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ListViews',
      theme: ThemeData(
          visualDensity: VisualDensity.adaptivePlatformDensity,
          primaryColor: Colors.blue
      ),
      home: NotificationListener<OverscrollIndicatorNotification>(// để che hiệu ứng glow khi cuộn ở 2 đầu
        onNotification: (OverscrollIndicatorNotification overscroll) {
          overscroll.disallowGlow(); return true;
        },child:DefaultTabController(
        length: 3,
        child:Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor:  Color(0xFF373737),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(60.0), // here the desired height
              child:AppBar(// bỏ comment để hiện thanh tài nguyên trên cùng màn hình
                /*title:Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  PointRowTop(context, 0, 'assets/images/one.png'),
                  PointRowTop(context, 0, 'assets/images/heart.png'),
                  PointRowTop(context, 0, 'assets/images/note.png'),
                  PointRowTop(context, 0, 'assets/images/gems.png'),
                ],
              ),*/
                bottom: TabBar(
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                  indicatorColor: Colors.white12,
                  indicatorWeight: 10.0,
                  labelColor: Colors.white,
                  tabs: [
                    Tab(child: Align(
                      alignment: Alignment.center,
                      child: Text("Nhạc Việt"),
                    ),),
                    Tab(child: Align(
                      alignment: Alignment.center,
                      child: Text("Nhạc\nNước Ngoài",textAlign: TextAlign.center,),
                    ),
                    ),
                    Tab(child: Align(
                      alignment: Alignment.center,
                      child: Text("Yêu thích",textAlign: TextAlign.center,),
                    ),),
                  ],
                ),
              ),),
            body: TabBarView(
              children: [
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/background.jpg'), fit: BoxFit.cover)
                    ),
                    child:BodyLayout(0)),
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/background.jpg'), fit: BoxFit.cover)
                    ),
                    child:BodyLayout(0)),
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/background.jpg'), fit: BoxFit.cover)
                    ),
                    child:BodyLayout(0)),
              ],
            ),
            bottomNavigationBar: BottomNavLayout()
        ),
      ),
      ),);
  }
}

class BodyLayout extends StatelessWidget {
  int tabIndex;
  BodyLayout(int tabIndex){
    this.tabIndex=tabIndex;
  }
  @override
  Widget build(BuildContext context) {
    return songsListView(context,tabIndex);
  }
}
class BottomNavLayout extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return bottomNav(context);
  }
}

Widget songsListView(BuildContext context,tabIndex) {
  //tên bài hát
  final data = getSongs(tabIndex);
  final titles= data[0];
  final artists= data[1];
  final icons= data[2];
  final List<double> difficulties=data[3];
  //final beatRate=data[3];
  //final difficulty=data[4];
  return NotificationListener<OverscrollIndicatorNotification>(// tắt hiệu ứng glow khi cuộn tới cuối list/ đầu list
    onNotification: (OverscrollIndicatorNotification overscroll) {
      overscroll.disallowGlow(); return true;
    },
    child: ListView.builder(
      itemCount: titles.length,
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              final snackBar = SnackBar(content: Text(titles[index]));
              Scaffold.of(context).showSnackBar(snackBar);
            },
            child:Card(
              child: ListTile(
                isThreeLine: true,
                leading:Container(
                    height: double.infinity,
                    child:ImageIcon(
                      AssetImage('assets/images/music-note.png'),
                      size: 50,
                      color: Color(0xFF3A5A98),
                    ),//replaced by image if available
                ),
                title: Text(titles[index]),
                subtitle:  Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      flex:3,
                      child:Container(
                        height: 30,
                        child: new MarqueeWidget(
                        text:artists[index],
                          textStyle: new TextStyle(fontSize: 16.0),
                        scrollAxis: Axis.horizontal,),
                    //Text(,overflow: TextOverflow.ellipsis,),
                    ),),
                    Flexible(
                      flex: 3,
                      child:SmoothStarRating(
                        rating: difficulties[index],
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
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
      ),
      BottomNavigationBarItem(
        icon: new Icon(Icons.library_music),
        title: new Text('Songs',
            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
      ),
      BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          title: Text('Settings',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20))
      )
    ],
  );
}
List getSongs(tabIndex){
  //TODO fetch data from server
  //tên bài hát
  final titles = ['Little Star', 'Jingle Bells', 'Canon', 'Two Tigers',
    'The Blue Danube', 'Happy New Year', 'Beyer No. 8', 'Bluestone Alley', 'Reverie'];
  //tên ca sĩ/nhóm nhạc
  final artists=['English Folk Music', 'James Lord Pierpont', 'Johann Pachelbel', 'French Folk Music',
    'Johann Strauss II', 'English Folk Music', 'Ferdinand Beyer', 'Congfei Wei', 'Claude Debussy'];
  //icons sẽ được thay bằng hình nhạc sau
  final icons = [Icons.music_note, Icons.music_note,Icons.music_note,Icons.music_note,
    Icons.music_note,Icons.music_note,Icons.music_note,Icons.music_note,Icons.music_note];
  final List<double> difficulties=[1,1,1,2,3,4,4,5,5];
  return [titles,artists,icons,difficulties];
}
class Song{
  //Thông tin chung của bài nhạc
  String id;
  String name;
  List<String> artists;
  int difficulty;
  String image;//đường dẫn tới file ảnh local/database

  //Thông tin hỗ trợ cho trò chơi
  String music_dir;//đường dẫn tới file âm thanh
  String notes_dir;//đường dẫn tới file map các notes của bài nhạc
  String highscore;//mặc định =0
  Song(id,name,artists,difficulty,image,music_dir,notes_dir){
    this.id=id;
    this.name=name;
    this.artists=artists;
    this.difficulty=difficulty;
    this.image=image;
    this.music_dir=music_dir;
    this.notes_dir=notes_dir;
  }
  Song.fromJson(this.id, Map data) {
    name = data['name'];
    artists=data['artists'];
    difficulty=data['difficulty'];
    image=data['image'];
    music_dir=data['music_dir'];
    notes_dir=data['notes_dir'];
    if (name == null) {
      name = '';
    }
    if(artists==null){
      artists=='';
    }
    if(difficulty==null){
      difficulty==1;
    }
    if(image==null){
      image=='';
    }
    if(music_dir==null){
      music_dir=='';
    }
    if(notes_dir==null){
      notes_dir=='';
    }

  }
  void getHighscore(userID){
    //TODO get highscore from database
  }

}