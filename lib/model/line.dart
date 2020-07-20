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
      //specify note distance from top
      int index = currentNote.indexOf(note);
      double offset = (3 - index + animation.value) * tileHeight;
      return Transform.translate(
        offset: Offset(0, offset),
        child: Tile(
          height: tileHeight,
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
