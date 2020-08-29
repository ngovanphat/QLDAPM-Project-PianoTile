import 'package:flutter/material.dart';
import 'package:piano_tile/model/note.dart';
import 'package:piano_tile/model/tile.dart';

class Line extends AnimatedWidget {
  final int lineNumber;
  final List<Note> currentNote;
  final Function(Note) onTileTap;

  const Line(
      {Key key,
      this.currentNote,
      this.lineNumber,
      this.onTileTap,
      Animation<double> animation})
      : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    Animation<double> animation = super.listenable;
    //get heights
    double height = MediaQuery.of(context).size.height;
    double tileHeight = height / 4;

    // get only note for that line

    List<Note> thisLineNotes =
        currentNote.where((note) => note.line == lineNumber).toList();

    // map note widget
    List<Widget> tiles = thisLineNotes.map((note) {
//      //specify note distance from top
//      int index = currentNote.indexOf(note);
//
//      // to make tile higher
//      double myTileHeight = 2 * tileHeight;
//      double offset =
//          (3 - index + animation.value) * myTileHeight - 2 * myTileHeight;

      // relative index are init when init notes
      int index = note.index - currentNote[0].index;
//      debugPrint('note order: ${note.orderNumber} , index: $index');

      // in case some tile longer
      // we need to make room for tile
      double myTileHeight = note.height * tileHeight;
      double additionalSpace = 0;
      if(note.height == 2){
        additionalSpace = tileHeight;
      }
      else if(note.height == 3) {
        additionalSpace = 2 * tileHeight;
      }

      // in case of 2-tile note has not yet passed all
      // but new animation reset
      // so need to add padding for each current note
      double padding = 0;
      if(currentNote[0].height > 1
          && currentNote[0].pass > 0
          && currentNote[0].pass < currentNote[0].height){
        padding = currentNote[0].pass * tileHeight;
      }

      // calculate offset
      double offset = (3 - index) * tileHeight
          - additionalSpace
          + animation.value * tileHeight
          + padding
      ;

      return Transform.translate(
        offset: Offset(0, offset),
        child: Tile(
          height: myTileHeight,
          state: note.state,
          onTap: () => onTileTap(note),
        ),
      );
    }).toList();

    return SizedBox.expand(
      child: Stack(
        children: tiles,
      ),
    );
  }
}
