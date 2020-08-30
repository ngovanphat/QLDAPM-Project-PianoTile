import 'package:flutter/material.dart';
import 'package:piano_tile/views/home.dart';

class PauseButton extends StatelessWidget {
  final VoidCallback pauseCallback;
  final Function(bool) onResumePressed;
  PauseButton({@required this.onResumePressed, this.pauseCallback});

  Color _iconColor = Colors.lightBlue;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.only(top: 20),
        child: IconButton(
          icon: Icon(Icons.pause, color: _iconColor),
          iconSize: 50,
          onPressed: () {
            pauseCallback();
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
                        new FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.play_arrow,
                                    color: Colors.white, size: 50),
                                Text(
                                  "Resume",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                )
                              ],
                            ),
                            onPressed: () {
                              onResumePressed(true);
                              Navigator.of(context).pop();
                            }),
                        Padding(padding: const EdgeInsets.only(top: 30)),
                        new FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.refresh,
                                    color: Colors.white, size: 50),
                                Text(
                                  "Restart",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                )
                              ],
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }),
                        Padding(padding: const EdgeInsets.only(top: 30)),
                        new FlatButton(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(Icons.clear,
                                    color: Colors.white, size: 50),
                                Text(
                                  "Leave",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 14),
                                )
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Home()),
                              );
                            }),
                      ]),
                ),
              ),
            );
          },
        ));
  }
}
