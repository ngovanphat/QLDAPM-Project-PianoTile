class Note {
  // values for GUI
  final int orderNumber;
  final int line;
  NoteState state = NoteState.ready;
  int index;
  int height;
  int pass = 0;

  // values for playing sound
  int tickValue;
  List<int> midiValue;
  List<int> velocityValue;

  // constructor
  Note(
      {this.orderNumber,
      this.line,
      this.tickValue,
      this.midiValue,
      this.velocityValue});

  // reset method
  void reset() {
    this.state = NoteState.ready;
  }
}

enum NoteState { ready, tapped, missed }
