class Note {
  final int orderNumber;
  final int line;
  final midi1;
  final midi2;
  NoteState state = NoteState.ready;

  Note(this.orderNumber, this.line, this.midi1, this.midi2);
}

enum NoteState { ready, tapped, missed }
