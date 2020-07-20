import 'package:flutter/material.dart';

class PauseButton extends StatefulWidget {
  @override
  _PressedState createState() => _PressedState();
}
class _PressedState extends State<PauseButton>{
  Color _iconColor = Colors.lightBlue;

  bool _pressed = false;

  void triggered(){
    setState(() {
      if(_pressed){
        _iconColor = Colors.blueAccent;
      } else{
        _iconColor = Colors.lightBlue;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (details) {
        _pressed = !_pressed;
        triggered();
      },
      onPointerUp: (details) {
        _pressed = false;
        triggered();
      },
      child: Container(
        padding: const EdgeInsets.only(
        top:  20
        ),
        child: IconButton(
          icon: Icon(Icons.pause, color: _iconColor), iconSize: 50,
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => Material(
                type: MaterialType.transparency,
                  // Aligns the container to center
                  child: Center(
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new FlatButton(child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.play_arrow, color: Colors.white, size: 50),
                            Text("Resume", style: TextStyle(color: Colors.white, fontSize: 14),)],
                        ), onPressed: (){Navigator.of(context).pop();}),
                        Padding(padding: const EdgeInsets.only(top:  30)),
                        new FlatButton(child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.refresh, color: Colors.white, size: 50),
                            Text("Restart", style: TextStyle(color: Colors.white, fontSize: 14),)],
                        ), onPressed: (){Navigator.of(context).pop();}),
                        Padding(padding: const EdgeInsets.only(top:  30)),
                        new FlatButton(child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.clear, color: Colors.white, size: 50),
                            Text("Leave", style: TextStyle(color: Colors.white, fontSize: 14),)],
                        ), onPressed: (){Navigator.of(context).pop();}),
                      ]),
                ),
              ),
            );
          },
      )
      )
    );
  }
}
