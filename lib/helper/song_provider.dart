import 'package:piano_tile/model/note.dart';

import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:core';
import 'dart:math';

Future<List<Note>> initNotes() async{

  // read file data
  String content = await loadAsset('assets/song/jingle_bells.mid.txt');

  // convert data to list of notes
  return await convertToNotes(content);


}


Future<List<Note>> convertToNotes(String fileContent) async{

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
    print('Line $i: ${lines[i]}');

    List<String> tokens = lines[i].split(' ');
    print('token0:${tokens[0]}, token1:${tokens[1]}, token2:${tokens[2]}');
    // parse to integer
    var tick = int.parse(tokens[0]);
    var midi = int.parse(tokens[1]);
    var velocity = int.parse(tokens[2]);


    // check if same tick
    if(currentTick == tick || velocity == 0){
      // this means these midi values should be played at the same time
      // so, assign midi values for same note

      currentNote.midiValue.add(midi);
      currentNote.velocityValue.add(velocity);

    }
    else{

      List<int> midis = new List<int>();
      midis.add(midi);
      List<int> velocities = new List<int>();
      velocities.add(velocity);

      // random line from 0 to 3
      int random = rng.nextInt(4);
      // avoid 2 adjacent tiles in same line
      while(random == currentRandom){
        random = rng.nextInt(4);
      }

      // assign to new note
      Note note = new Note(
          orderNumber: countNote,
          line: random,
          tickValue: tick,
          midiValue: midis,
          velocityValue: velocities
      );

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



  return notes;
  // end of function
}

// read asset file
Future<String> loadAsset(String path) async {
  return await rootBundle.loadString(path);
}






