import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:piano_tile/model/Song.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';
import 'package:sembast/utils/sembast_import_export.dart';
/*
====================================================================
Reference: https://medium.com/@hrishikesh.deshmukh445/persist-data-with-sembast-nosql-database-in-flutter-2b6c5110170f
====================================================================
*/

class AppDatabase {
  static final AppDatabase _singleton = AppDatabase._();

  static AppDatabase get instance => _singleton;

  // Completer is used for transforming synchronous code into asynchronous code.
  Completer<Database> _dbOpenCompleter;

  // A private constructor. Allows us to create instances of AppDatabase
  // only from within the AppDatabase class itself.
  AppDatabase._();

  // Database object accessor
  Future<Database> get database async {
    // If completer is null, AppDatabaseClass is newly instantiated, so database is not yet opened
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      // Calling _openDatabase will also complete the completer with database instance
      _openDatabase();
    }
    // If the database is already opened, awaiting the future will happen instantly.
    // Otherwise, awaiting the returned future will take some time - until complete() is called
    // on the Completer in _openDatabase() below.
    return _dbOpenCompleter.future;
  }

  Future _openDatabase() async {
    // Get a platform-specific directory where persistent app data can be stored
    final appDocumentDir = await getApplicationDocumentsDirectory();
    // Path with the form: /platform-specific-directory/demo.db
    final dbPath = join(appDocumentDir.path, 'Song.db');

    final database = await databaseFactoryIo.openDatabase(dbPath);

    // Any code awaiting the Completer's future will now start executing
    _dbOpenCompleter.complete(database);
  }
}

class SongDAO {
  static const String folderName = "Songs";
  final _songFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;
  Future<bool> isEmpty(String type) async {
    final finder = Finder(filter: Filter.matches("id", type));
    return await _songFolder.findFirst(await _db, finder: finder) == null
        ? true
        : false;
  }

  Future<int> countSongs(String type) async {
    var content = await exportDatabase(await _db);
    /*JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    String prettyprint = encoder.convert(content);
    prettyprint.split('\n').forEach((element) => print(element));*/
    return await _songFolder.count(await _db,
        filter: Filter.matches("id", type));
  }

  Future insertSong(Song song) async {
    List<String> existingSongs = await getIdList(song.typeOfSong());
    if (existingSongs.contains(song.getId()))
      updateSong(song);
    else {
      await _songFolder.add(await _db, song.toJson());
      print('Song Inserted successfully !!');
    }
  }

  Future updateSong(Song song) async {
    final finder = Finder(filter: Filter.equals("id", song.id));
    await _songFolder.update(await _db, song.toJson(), finder: finder);
  }

  Future delete(Song song) async {
    final finder = Finder(filter: Filter.equals('id', song.id));
    await _songFolder.delete(await _db, finder: finder);
  }

  Future deleteAll() async {
    await _songFolder.delete(await _db);
  }

  Future<List<String>> getIdList(String type) async {
    final recordSnapshot = await _songFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final String songId = snapshot.value["id"];
      return songId;
    }).toList();
  }

  Future<Song> getSongById(String id) async {
    final finder =
        Finder(filter: Filter.matchesRegExp('id', new RegExp('^' + id + r'$')));
    final recordSnapshot =
        await _songFolder.findFirst(await _db, finder: finder);
    debugPrint("Finding ID " + id);
    if (recordSnapshot != null) return Song.fromJson(recordSnapshot.value);
    return null;
  }

  Future<List<Song>> getAllSongs(String type) async {
    //List yêu thích ko load là do còn file local mấy bài cũ, bỏ uncomment deleteAll(),
    //chạy 1 lần r xóa deleteAll() đi là lần sau đó bình thường.
    //deleteAll();
    switch (type) {
      case "VN":
        {
          final finder = Finder(filter: Filter.matches("id", 'VN'));
          final recordSnapshot =
              await _songFolder.find(await _db, finder: finder);
          return recordSnapshot.map((snapshot) {
            final song = Song.fromJson(snapshot.value);
            return song;
          }).toList();
        }
        break;
      case "NN":
        {
          final finder = Finder(filter: Filter.matches("id", 'NN'));
          final recordSnapshot =
              await _songFolder.find(await _db, finder: finder);
          return recordSnapshot.map((snapshot) {
            final song = Song.fromJson(snapshot.value);
            return song;
          }).toList();
        }
        break;
      case "YT":
        {
          final finder = Finder(
              filter: Filter.equals("isFavorited", true, anyInList: false),
              sortOrders: [SortOrder('id'), SortOrder('highscore')]);
          final recordSnapshot =
              await _songFolder.find(await _db, finder: finder);
          return recordSnapshot.map((snapshot) {
            final song = Song.fromJson(snapshot.value);
            debugPrint("Fav Song Id" + song.getId());
            return song;
          }).toList();
        }
        break;
      case "Highscore":
        {
          final finder = Finder(
              filter: Filter.greaterThan("highscore", 0),
              sortOrders: [SortOrder('id')]);
          final recordSnapshot =
              await _songFolder.find(await _db, finder: finder);
          return recordSnapshot.map((snapshot) {
            final song = Song.fromJson(snapshot.value);
            return song;
          }).toList();
        }
        break;
      default: //all
        {
          final recordSnapshot = await _songFolder.find(await _db);
          return recordSnapshot.map((snapshot) {
            final song = Song.fromJson(snapshot.value);
            return song;
          }).toList();
        }
        break;
    }
  }
}
