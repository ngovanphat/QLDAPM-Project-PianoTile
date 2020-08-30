import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';

// import lib of us
import 'package:audioplayers/audio_cache.dart';
import 'package:piano_tile/helper/song_provider.dart';
import 'package:piano_tile/model/ad_manager.dart';
import 'package:piano_tile/model/Song.dart';
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
  final Song song;
  const GamePlay({Key key, this.song}) : super(key: key);
  @override
  GamePlayState createState() => GamePlayState(song: song);
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
  bool isRewardedAdReady;
  bool ad_loaded = false;
  MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['flutterio', 'beautiful apps'],
    contentUrl: 'https://flutter.io',
    childDirected: false,
    testDevices: <String>[], // Android emulators are considered test devices
  );

  Song song;
  // midi player
  FlutterMidi midi = new FlutterMidi();

  // notes
  List<Note> notes = null;
  Future<String> statusOfInitNotes = null;

  GamePlayState({this.song});

  // song info
//  String songName = 'canond.mid.txt';
  String songName = 'tim_lai_bau_troi.mid.txt';
  //TODO: change song to play here
  int levelRequired = 0;
  int expReward = 0;
  int hard = 0;

  SharedPreferences prefs = null;

  Future<String> doInitNotes() async {
    // first, check if song requires higher level then current level
    DatabaseReference refSong =
        FirebaseDatabase.instance.reference().child('Songs');

    DataSnapshot snapshot1 = await refSong.child('NhacViet').once();
    Map<dynamic, dynamic> songs = snapshot1.value;
    bool isFound = false;
    songs.forEach((key, value) {
      if (value['filename'] == songName) {
        this.levelRequired = value['levelRequired'];
        this.expReward = value['expReward'];
        this.hard = value['hard'];
        isFound = true;
      }
    });
    if (isFound == false) {
      snapshot1 = await refSong.child('NhacNuocNgoai').once();
      songs = snapshot1.value;
      songs.forEach((key, value) {
        if (value['filename'] == songName) {
          this.levelRequired = value['levelRequired'];
          this.expReward = value['expReward'];
          this.hard = value['hard'];
          isFound = true;
        }
      });
    }
    print(
        '[game_play] level need: $levelRequired, expReward: $expReward, hard: $hard');

    // here, already have song info
    prefs = await SharedPreferences.getInstance();
    int currentLevel = prefs.getInt(sharedPrefKeys.getLevelKey());
    if (currentLevel < this.levelRequired) {
      // end, not allow to play

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                  "This song requires level ${this.levelRequired} or higher"),
              actions: <Widget>[
                FlatButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                )
              ],
            );
          }).then((_) {
        // return to previous page
        Navigator.pop(context);
      });

      return 'fail_level_required';
    }

    // if ok, then get notes
    notes = await initNotes(song.getNotes());
    return 'done';
  }

  @override
  void initState() {
    super.initState();

    isRewardedAdReady = false;

    // TODO: Set Rewarded Ad event listener
    RewardedVideoAd.instance.listener = _onRewardedAdEvent;

    // TODO: Load a Rewarded Ad
    _loadRewardedAd();

    RewardedVideoAd.instance
        .load(adUnitId: RewardedVideoAd.testAdUnitId, targetingInfo: targetingInfo)
        .catchError((e) => print("error in loading 1st time"))
        .then((v) => setState(() => ad_loaded = v));

    // ad listener
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
      if (event == RewardedVideoAdEvent.closed) {
        RewardedVideoAd.instance
            .load(adUnitId: RewardedVideoAd.testAdUnitId, targetingInfo: targetingInfo)
            .catchError((e) => print("error in loading again"))
            .then((v) => setState(() => ad_loaded = v));
      }
    };
    // init notes
//    initNotes().then((value) {
//      notes = value;
//      setState(() {});
//      print('success loading notes');
//      print('length: ${notes.length}');
//    });
    song = widget.song;
    if (song == null) {
      //for home page song
      song = new Song("-1", "Shining The Morning", "abc", 1, " ",
          notes_dir:
              "https://firebasestorage.googleapis.com/v0/b/melody-tap.appspot.com/o/canond.mid.txt?alt=media&token=0d3fbea0-61be-4e9e-832e-dcec4bf16727");
    }
    statusOfInitNotes = doInitNotes();

    // init midi player with sound font
    midi.unmute();
    rootBundle.load("assets/audio/piano.sf2").then((sf2) {
      midi.prepare(sf2: sf2, name: "piano.sf2");
    });

    // milli-second = time to pass a single tile (1/4 screen)
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 400));

    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        // animation complete means 1 tileHeight has passed
        notes[currentNoteIndex].pass++;

        if (notes[currentNoteIndex].state != NoteState.tapped &&
            notes[currentNoteIndex].pass == notes[currentNoteIndex].height) {
          // end game
          setState(() {
            isPlaying = false;
            notes[currentNoteIndex].state = NoteState.missed;
          });
          animationController
              .reverse()
              .then((_) => showFinishDialog(status: "game_over"));
        } else {
          if (notes[currentNoteIndex].pass == notes[currentNoteIndex].height) {
            setState(() {
              ++currentNoteIndex;
            });
          }

          if (currentNoteIndex >= notes.length) {
            // song completed here
            showFinishDialog(status: "completed");
          } else {
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
    return WillPopScope(
      child: Material(
          child: FutureBuilder<String>(
        future: statusOfInitNotes,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData && snapshot.data == 'done') {
            return Stack(
              fit: StackFit.passthrough,
              children: <Widget>[
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
                pauseButton(),
              ],
            );
          } else if (snapshot.hasData &&
              snapshot.data == 'fail_level_required') {
            return Container();
          } else {
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
      )),
      onWillPop: () async {
        return false;
      },
    );
  }

  void restart() {
    setState(() {
      hasStarted = false;
      isPlaying = true;

      notes.forEach((note) {
        note.reset();
      });
      points = 0;
      currentNoteIndex = 0;
    });
    animationController.reset();
  }

  void _loadRewardedAd() {
    RewardedVideoAd.instance.load(
      targetingInfo: MobileAdTargetingInfo(),
      adUnitId: AdManager.rewardedAdUnitId,
    );
  }

  void _onRewardedAdEvent(RewardedVideoAdEvent event,
      {String rewardType, int rewardAmount}) {
    switch (event) {
      case RewardedVideoAdEvent.loaded:
        setState(() {
          isRewardedAdReady = true;
        });
        break;
      case RewardedVideoAdEvent.closed:
        setState(() {
          isRewardedAdReady = false;
        });
        _loadRewardedAd();
        break;
      case RewardedVideoAdEvent.failedToLoad:
        setState(() {
          isRewardedAdReady = false;
        });
        print('Failed to load a rewarded ad');
        break;
      case RewardedVideoAdEvent.rewarded:
        print('recover');
        break;
      default:
      // do nothing
    }
  }

  void showFinishDialog({String status}) async {
    if (status == "game_over") {
      // ask user if wan to recover game with ads, gems
      showAskRecoveryDialog();
    } else {
      showResultDialog();
    }
  }

  void showAskRecoveryDialog() async {
    // get number of gems for recovering
    DataSnapshot data = await FirebaseDatabase.instance
        .reference()
        .child('gemDefinition/continue')
        .once();
    int numGemToRecover = data.value;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Score: $points"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                  Navigator.pop(context);
                  await RewardedVideoAd.instance.show().catchError((e) => print("error in showing ad: ${e.toString()}"));
                  setState(() => ad_loaded = false);
                  },
                child: Text("Recover with ads")
              ),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    recoverWithGems(numGemToRecover);
                  },
                  child: Text("Recover with $numGemToRecover Gems")),
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showResultDialog();
                  },
                  child: Text("Exit")),
            ],
          );
        });
  }

  void showResultDialog() async {
    // calculate exp, level, gem
    int expGot = (this.expReward * this.points / notes.length).round();
    int newExp = prefs.getInt(sharedPrefKeys.getExpKey()) + expGot;
    int newGem = prefs.getInt(sharedPrefKeys.getGemKey());
    int newLevel = prefs.getInt(sharedPrefKeys.getLevelKey());
    int newNextExp = prefs.getInt(sharedPrefKeys.getNextExpKey());

    bool isLevelUp = newExp > prefs.getInt(sharedPrefKeys.getNextExpKey());
    int gemReward = 0;
    if (isLevelUp) {
      // for convient, just increase 1 level
      // maybe increase more...?

      // resolve level and get next-exp value
      int levelValue = 1;
      int nextExpValue = 0;
      gemReward = 0;
      DataSnapshot data = await FirebaseDatabase.instance
          .reference()
          .child('levelDefinition')
          .once();
      List<dynamic> levels = data.value;
      for (int i = 0; i < levels.length; i++) {
        Map<dynamic, dynamic> level = levels[i];
        if (level['expRequired'] > newExp) {
          levelValue = level['level'] - 1;
          nextExpValue = level['expRequired'];
          gemReward = level['gemReward'];
          break;
        }
      }
      print(
          '[main] level: $levelValue, next exp: $nextExpValue, reward: $gemReward');

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
    if (prefs.getInt(sharedPrefKeys.userType) == sharedPrefValues.USER) {
      String id = prefs.getString(sharedPrefKeys.getIdKey());
      DatabaseReference user =
          FirebaseDatabase.instance.reference().child('account/$id');
      user.update({'exp': newExp});
      user.update({'gem': newGem});
    }
    print('[game_play] Score: $points\nExp: $newExp\nGem: $newGem'
        '\nLevel: $newLevel\nNext exp: $newNextExp');

    // show
    String resultString = "Score: $points\nExp: +$expGot";
    if (isLevelUp) {
      resultString += "\nNew level: $newLevel\nGem reward: +$gemReward";
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(resultString),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => MusicList())),
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
        });
  }

  void recoverWithGems(int gemRequired) {
    // check if enough gem to recover
    int currentGems = prefs.get(sharedPrefKeys.getGemKey());

    // if not
    if (currentGems < gemRequired) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(
                  "$currentGems gems is not enough! Recovery required $gemRequired gems"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showAskRecoveryDialog();
                    },
                    child: Text("OK")),
              ],
            );
          });
      return;
    }

    // if enough
    // subtract gems
    currentGems -= gemRequired;
    // update local file
    prefs.setInt(sharedPrefKeys.getGemKey(), currentGems);
    // update firebase if user logged in
    String userId = prefs.getString(sharedPrefKeys.getIdKey());
    FirebaseDatabase.instance
        .reference()
        .child('account/$userId')
        .update({'gem': currentGems});

    // show result
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Your gems: $currentGems (-$gemRequired)"),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    recoverNoteMissed();
                  },
                  child: Text("OK")),
            ],
          );
        });
  }

  void recoverNoteMissed() {
    setState(() {
      // need to subtract pass by 1
      // because animation maybe add 1 in previous completion
      notes[currentNoteIndex].pass -= 1;
      notes[currentNoteIndex].state = NoteState.ready;

      hasStarted = false;
      isPlaying = true;
    });
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
        animationController.forward(from: 0);
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
    if (notes == null) {
      return Container();
    }

    int end = currentNoteIndex + 5;
    if (end > notes.length) {
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

  pauseButton() {
    return Align(
      alignment: Alignment.topRight,
      child: PauseButton(
        pauseCallback: () {
          setState(() {
            isPlaying = true;
          });
        },
        onResumePressed: (bool resume) {
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
