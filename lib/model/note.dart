class Note{

  final int orderNumber;
  final int line;

  NoteState state = NoteState.ready;

  Note({this.line , this.orderNumber});

}

enum NoteState { ready, tapped, missed }