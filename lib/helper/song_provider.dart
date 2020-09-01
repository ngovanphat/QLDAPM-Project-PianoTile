import 'package:flutter/cupertino.dart';
import 'package:piano_tile/model/note.dart';

import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permissions_plugin/permissions_plugin.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<List<Note>> initNotes(String notedir) async {
  String pathToSave="";
  String content="";
  debugPrint("notedir"+notedir);
  if(notedir.contains("assets/song/")){
    pathToSave=notedir;
    content=await rootBundle.loadString(notedir);
  }else{
    // firebase storage
    var storage = FirebaseStorage.instance;
    StorageReference ref = await storage.getReferenceFromUrl(notedir);

    // song name
    var dir = await getExternalStorageDirectory();
    var name = await ref.getName();
    pathToSave = '${dir.path}/${name}';
    // check if song already in local folder
    final File tempFile = File(pathToSave);
    if (tempFile.existsSync() == false) {
      // if not, download song
      await downloadFile(ref, pathToSave);
    }

    // read file data
    content = await loadFile(pathToSave);
  }



  // convert data to list of notes
  return await convertToNotes(content);
}

// download file from firebase storage
// paramFileName: name of file in storage bucket
Future<void> downloadFile(StorageReference ref, String pathToSave) async {
  // check permissions
  Map<Permission, PermissionState> permission =
      await PermissionsPlugin.checkPermissions(
          [Permission.WRITE_EXTERNAL_STORAGE]);
  print(
      'permission state: ${permission[Permission.WRITE_EXTERNAL_STORAGE].toString()}');

  // if not granted, try ask user for it
  if (permission[Permission.WRITE_EXTERNAL_STORAGE] !=
      PermissionState.GRANTED) {
    Map<Permission, PermissionState> permission2 =
        await PermissionsPlugin.requestPermissions(
            [Permission.WRITE_EXTERNAL_STORAGE]);

    if (permission2[Permission.WRITE_EXTERNAL_STORAGE] !=
        PermissionState.GRANTED) {
      print('[download] permission not granted');
      return;
    }
  }

  // create local file
  String filePath = pathToSave;

  final File tempFile = File(filePath);
  print('[download] path: ' + filePath);
  if (tempFile.existsSync()) {
    await tempFile.delete();
  }
  await tempFile.create();
  assert(await tempFile.readAsString() == "");

  // write downloaded data to local file
  final StorageFileDownloadTask task = ref.writeToFile(tempFile);
  final int byteCount = (await task.future).totalByteCount;
  print('[download] $byteCount');

  // show result
  final String name = await ref.getName();
  final String bucket = await ref.getBucket();
  final String path = await ref.getPath();

  print('[download] name: $name, bucket: $bucket, path: $path');
}

Future<List<Note>> convertToNotes(String fileContent) async {
  // split into lines
  LineSplitter ls = new LineSplitter();
  List<String> lines = ls.convert(fileContent);

  // variables
  int currentTick = -999;
  Note currentNote = null;
  int currentRandom = -999;
  int countNote = 0;
  var rng = new Random();
  List<Note> notes = new List<Note>();

  // process each line
  for (var i = 0; i < lines.length; i++) {
//    print('Line $i: ${lines[i]}');

    List<String> tokens = lines[i].split(' ');
//    print('token0:${tokens[0]}, token1:${tokens[1]}, token2:${tokens[2]}');
    // parse to integer
    var tick = int.parse(tokens[0]);
    var midi = int.parse(tokens[1]);
    var velocity = int.parse(tokens[2]);

    // check if same tick
    if (currentTick == tick || velocity == 0) {
      // this means these midi values should be played at the same time
      // so, assign midi values for same note

      currentNote.midiValue.add(midi);
      currentNote.velocityValue.add(velocity);
    } else {
      List<int> midis = new List<int>();
      midis.add(midi);
      List<int> velocities = new List<int>();
      velocities.add(velocity);

      // random line from 0 to 3
      int random = rng.nextInt(4);
      // avoid 2 adjacent tiles in same line
      while (random == currentRandom) {
        random = rng.nextInt(4);
      }

      // assign to new note
      Note note = new Note(
          orderNumber: countNote,
          line: random,
          tickValue: tick,
          midiValue: midis,
          velocityValue: velocities);

      // temp variable for later checking
      currentTick = tick;
      currentNote = note;
      currentRandom = random;
      countNote++;

      // add to list note for return
      notes.add(note);
    }

    // end of for
  }

  // calculate heights for all notes
  // calculate first note
  Note note = notes[0];
  note.index = 0;
  note.height = 1;

  int velocityThreshold = 50;

  if (note.velocityValue[0] < velocityThreshold) {
    note.height = 2; // take 2 tile
  }

  // the rest notes based on first note
  for (var i = 1; i < notes.length; i++) {
    Note postNote = notes[i];
    postNote.height = 1;
    if (note.velocityValue[0] < velocityThreshold) {
      postNote.height = 2;
    }

    postNote.index = notes[i - 1].index + notes[i - 1].height;
  }

  return notes;
  // end of function
}

// read asset file
Future<String> loadAsset(String path) async {
  return await rootBundle.loadString(path);
}

// read file in external storage
Future<String> loadFile(String path) async {
  File file = File(path);
  return await file.readAsString();
}
