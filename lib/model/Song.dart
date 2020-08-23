import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Song {
  //Thông tin chung của bài nhạc
  String id;
  String name;
  String artists;
  int difficulty;
  String image; //đường dẫn tới file ảnh local/database

  //Thông tin hỗ trợ cho trò chơi
  String music_dir; //đường dẫn tới file âm thanh
  String notes_dir; //đường dẫn tới file map các notes của bài nhạc
  int highscore; //mặc định =0
  bool
      isFavorited; //mặc định = false - dùng để hiển thị bài hát yêu thích trong danh sách bài hát chung
  Song(id, name, artists, difficulty, image,
      {music_dir = '', notes_dir = '', highscore, isFavorited}) {
    this.id = id;
    this.name = name;
    this.artists = artists;
    this.difficulty = difficulty;
    this.image = image;
    this.music_dir = music_dir;
    this.notes_dir = notes_dir;
    this.highscore = highscore ?? 0;
    this.isFavorited = isFavorited ?? false;
  }
  String getId() {
    return this.id;
  }

  String getName() {
    return this.name;
  }

  String getArtists() {
    return this.artists;
  }

  int getDifficulty() {
    return this.difficulty;
  }

  String getImage() {
    return this.image;
  }
String getNotes(){
    debugPrint("note dir"+this.notes_dir);
    return this.notes_dir;
}
  void setId(id) {
    this.id = id;
  }

  void setName(name) {
    this.name = name;
  }

  void setArtists(artists) {
    this.artists = artists;
  }

  void setDifficulty(difficulty) {
    this.difficulty = difficulty;
  }

  void setImage(image) {
    this.image = image;
  }
  Song.fromJson(this.id, Map data) {
    name = data['name'];
    artists = data['artists'];
    difficulty = data['difficulty'];
    image = data['image'];
    music_dir = data['music_dir'];
    notes_dir = data['notes_dir'];
    if (name == null) {
      name = '';
    }
    if (artists == null) {
      artists == '';
    }
    if (difficulty == null) {
      difficulty == 1;
    }
    if (image == null) {
      image == '';
    }
    if (music_dir == null) {
      music_dir == '';
    }
    if (notes_dir == null) {
      notes_dir == '';
    }
  }
  void fetchHighscore(userID) {
    //TODO get highscore from database

  }
  void fetchFavorite(userID) {}
  int getHighscore() {
    return this.highscore;
  }

  bool getFavorite() {
    return this.isFavorited;
  }

  Future<int> setHighscore(newHighscore) async {
    //TODO write new highscore to database
    if (this.highscore > newHighscore) return 1;
    try {
      this.highscore = newHighscore;
      final FirebaseAuth auth = FirebaseAuth.instance;
      final FirebaseUser user = await auth.currentUser();
      final uid = user.uid;
      var db = FirebaseDatabase.instance.reference().child("HighScores/" + "abc");
      await db
          .child("/" + this.name)
          .update({'score': this.highscore, 'updateAt': Timestamp.now()});

      return 0;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void setFavorite() {
    //TODO add new favorite to user info
    this.isFavorited = false ? true : false;
  }
}
