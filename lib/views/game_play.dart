import 'package:flutter/material.dart';

// import lib of us
import 'package:audioplayers/audio_cache.dart';
import 'package:piano_tile/helper/song_provider.dart';
import 'package:piano_tile/model/note.dart';
import 'package:piano_tile/model/line_divider.dart';
import 'package:piano_tile/model/line.dart';
import 'package:piano_tile/model/pause_menu.dart';
import 'package:flutter_midi/flutter_midi.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:piano_tile/views/music_list.dart';


class GamePlay extends StatefulWidget {

  @override
  GamePlayState createState() => GamePlayState();

}

class GamePlayState<T extends GamePlay> extends State<T>
    with SingleTickerProviderStateMixin {
  AudioCache player = AudioCache();
  AnimationController animationController;
  int currentNoteIndex = 0;
  int points = 0;
  bool hasStarted = false;
  bool isPlaying = true;
  bool ispause = false;

  // midi player
  FlutterMidi midi = new FlutterMidi();

  // notes
  List<Note> notes = null;
  Future<String> statusOfInitNotes = null;
  String songName = 'canond.mid.txt';

  Future<String> doInitNotes() async {
    notes = await initNotes(songName);
    return 'done';
  }

  @override
  void initState() {
    super.initState();

    // init notes
//    initNotes().then((value) {
//      notes = value;
//      setState(() {});
//      print('success loading notes');
//      print('length: ${notes.length}');
//    });
    statusOfInitNotes = doInitNotes();



    // init midi player with sound font
    midi.unmute();
    rootBundle.load("assets/audio/piano.sf2").then((sf2) {
      midi.prepare(sf2: sf2, name: "piano.sf2");
    });

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        if (notes[currentNoteIndex].state != NoteState.tapped) {
          // end game
          setState(() {
            isPlaying = false;
            notes[currentNoteIndex].state = NoteState.missed;
          });
          animationController.reverse().then((_) => showFinishDialog());
        }
        else {
          setState(() {
            ++currentNoteIndex;
          });

          if(currentNoteIndex >= notes.length){
            // song finished here
            showFinishDialog();
          }
          else{
            animationController.forward(from: 0);
          }


        }
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    

    return Material(
      child: FutureBuilder<String>(

        future: statusOfInitNotes,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {

          if(snapshot.hasData && snapshot.data == 'done'){

            return Stack(
              fit: StackFit.passthrough,
              children:
              <Widget>[
                Image.asset(
                  'assets/images/background.jpg',
                  fit: BoxFit.cover,
                ),
                Row(
                  children: <Widget>[
                    _drawLine(0),
                    LineDivider(),
                    _drawLine(1),
                    LineDivider(),
                    _drawLine(2),
                    LineDivider(),
                    _drawLine(3)
                  ],
                ),
                drawPoints(),
                _pauseButton(),
              ],
            );
          }
          else{
            List<Widget> children;
            children = <Widget>[

            SpinKitWave(
            color: Colors.blue,
            size: 50.0,
            )
            ];

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children,
              ),
            );

       


          }
        },

      )


    );
  }

  void restart() {
    setState(() {
      hasStarted = false;
      isPlaying = true;
//      notes = initNotes();
      notes.forEach((note) {
        note.reset();
      });

      points = 0;
      currentNoteIndex = 0;
    });
    animationController.reset();
  }

  void showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Score: $points"),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MusicList())),
              child: Text("Exit"),
            ),
            FlatButton(
              onPressed: () => restart(),
              child: Text("Restart"),
            ),
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Recover with ads")
            )
          ],
        );
      }
    );
  }

  void onTap(Note note) {
    bool areAllPreviousTapped = notes
        .sublist(0, note.orderNumber)
        .every((n) => n.state == NoteState.tapped);
    if (areAllPreviousTapped) {
      if (!hasStarted) {
        setState(() {
          hasStarted = true;
        });
        animationController.forward();
      }
      _playNote(note);
      setState(() {
        note.state = NoteState.tapped;
        ++points;
      });
    }

  }

  _drawLine(int lineNumber) {
    // in case notes are loading
    // just show empty line
    if(notes == null){
      return Container();
    }

    int end = currentNoteIndex + 5;
    if(end > notes.length){
      // this means notes mostly run out
      end = notes.length;
    }

    return Expanded(
      child: Line(
        lineNumber: lineNumber,
        currentNote: notes.sublist(currentNoteIndex, end),
        onTileTap: onTap,
        animation: animationController,
      ),
    );
  }

  drawPoints() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 32,
        ),
        child: Text(
          "$points",
          style: TextStyle(
            color: Colors.red,
            fontSize: 60,
          ),
        ),
      ),
    );
  }

  _pauseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: PauseButton(
        pauseCallback: (){
          setState(() {
            isPlaying = true;
          });
        },
        onResumePressed: (bool resume){
          setState(() {
            isPlaying = resume;
          });
        },
      ),
    );
  }

  _playNote(Note note) {

    // note may contain multiple midi values
    // which can be played at the same time
    note.midiValue.forEach((value) {
      midi.playMidiNote(midi: value);
    });

  }

}
