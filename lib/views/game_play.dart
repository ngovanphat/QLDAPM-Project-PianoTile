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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piano_tile/helper/sharedPreferencesDefinition.dart';
import 'package:firebase_database/firebase_database.dart';

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

  // song info
//  String songName = 'canond.mid.txt';
  String songName = 'tim_lai_bau_troi.mid.txt';
  int levelRequired = 0;
  int expReward = 0;
  int hard = 0;

  SharedPreferences prefs = null;

  Future<String> doInitNotes() async {

    // first, check if song requires higher level then current level
    DatabaseReference refSong = FirebaseDatabase
        .instance
        .reference()
        .child('Songs');

    DataSnapshot snapshot1 = await refSong.child('NhacViet').once();
    Map<dynamic,dynamic> songs = snapshot1.value;
    bool isFound = false;
    songs.forEach((key, value){

      if(value['filename'] == songName){
        this.levelRequired =  value['levelRequired'];
        this.expReward = value['expReward'];
        this.hard = value['hard'];
        isFound = true;
      }
    });
    if(isFound == false){
      snapshot1 = await refSong.child('NhacNuocNgoai').once();
      songs = snapshot1.value;
      songs.forEach((key, value){

        if(value['filename'] == songName){
          this.levelRequired =  value['levelRequired'];
          this.expReward = value['expReward'];
          this.hard = value['hard'];
          isFound = true;
        }
      });
    }
    print('[game_play] level need: $levelRequired, expReward: $expReward, hard: $hard');

    // here, already have song info
    prefs = await SharedPreferences.getInstance();
    int currentLevel = prefs.getInt(sharedPrefKeys.getLevelKey());
    if(currentLevel < this.levelRequired){
      // end, not allow to play

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("This song requires level ${this.levelRequired} or higher"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                )
              ],
            );
          }
      ).then((_) {

        // return to previous page
        Navigator.pop(context);

      });


      return 'fail_level_required';
    }


    // if ok, then get notes
    notes = await initNotes(songName);
    return 'done';
  }

  @override
  void initState() {
    super.initState();

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
          animationController.reverse().then((_) => showFinishDialog(status: "game_over"));
        }
        else {
          setState(() {
            ++currentNoteIndex;
          });

          if(currentNoteIndex >= notes.length){
            // song completed here
            showFinishDialog(status: "completed");
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
          else if(snapshot.hasData && snapshot.data == 'fail_level_required'){

            return Container();

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

  void showFinishDialog({String status}) async {

    if(status == "game_over"){

      // ask user if wan to recover game with ads, gems
      showAskRecoveryDialog();
    }
    else{
      showResultDialog();
    }



  }

  void showAskRecoveryDialog() async{

    // get number of gems for recovering
    DataSnapshot data = await FirebaseDatabase.instance.reference().child('gemDefinition/continue').once();
    int numGemToRecover = data.value;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Score: $points"),
            actions: <Widget>[

              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Recover with ads")
              ),
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Recover with $numGemToRecover Gems")
              ),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showResultDialog();
                  },
                  child: Text("Exit")
              ),
            ],
          );
        }
    );

  }

  void showResultDialog() async{

    // calculate exp, level, gem
    int expGot = (this.expReward * this.points/notes.length).round();
    int newExp = prefs.getInt(sharedPrefKeys.getExpKey()) + expGot;
    int newGem = prefs.getInt(sharedPrefKeys.getGemKey());
    int newLevel = prefs.getInt(sharedPrefKeys.getLevelKey());
    int newNextExp = prefs.getInt(sharedPrefKeys.getNextExpKey());

    bool isLevelUp = newExp > prefs.getInt(sharedPrefKeys.getNextExpKey());
    int gemReward = 0;
    if(isLevelUp){
      // for convient, just increase 1 level
      // maybe increase more...?

      // resolve level and get next-exp value
      int levelValue = 1;
      int nextExpValue = 0;
      gemReward = 0;
      DataSnapshot data = await FirebaseDatabase.instance.reference()
          .child('levelDefinition')
          .once();
      List<dynamic> levels = data.value;
      for(int i = 0; i < levels.length; i++){

        Map<dynamic, dynamic> level = levels[i];
        if(level['expRequired'] > newExp){
          levelValue = level['level'] - 1;
          nextExpValue = level['expRequired'];
          gemReward = level['gemReward'];
          break;
        }

      }
      print('[main] level: $levelValue, next exp: $nextExpValue, reward: $gemReward');

      newGem += gemReward;
      newLevel = levelValue;
      newNextExp = nextExpValue;
    }

    // update local file
    prefs.setInt(sharedPrefKeys.getExpKey(), newExp);
    prefs.setInt(sharedPrefKeys.getGemKey(), newGem);
    prefs.setInt(sharedPrefKeys.getLevelKey(), newLevel);
    prefs.setInt(sharedPrefKeys.getNextExpKey(), newNextExp);

    // save to firebase if user already logged-in
    if(prefs.getInt(sharedPrefKeys.userType) == sharedPrefValues.USER){

      String id = prefs.getString(sharedPrefKeys.getIdKey());
      DatabaseReference user = FirebaseDatabase
          .instance
          .reference()
          .child('account/$id');
      user.update({'exp': newExp});
      user.update({'gem': newGem});
    }
    print('[game_play] Score: $points\nExp: $newExp\nGem: $newGem'
        '\nLevel: $newLevel\nNext exp: $newNextExp');

    // show
    String resultString = "Score: $points\nExp: +$expGot";
    if(isLevelUp){
      resultString += "\nNew level: $newLevel\nGem reward: +$gemReward";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(resultString),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MusicList())),
                child: Text("Play another song"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  restart();
                },
                child: Text("Restart"),
              ),
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context);
                },
                child: Text("Go Home"),
              ),
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
