import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/model/widget.dart';
import 'package:piano_tile/views/game_play.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        new AnimationController(vsync: this, duration: Duration(seconds: 5))
          ..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
            Container(
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  PointRowTop(context, 0, 'assets/images/one.png'),
                  PointRowTop(context, 0, 'assets/images/heart.png'),
                  PointRowTop(context, 0, 'assets/images/note.png'),
                  PointRowTop(context, 0, 'assets/images/gems.png'),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 100),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (_, child) {
                        return Transform.rotate(
                          angle: _animationController.value * 1 * 3.14,
                          child: child,
                        );
                      },
                      child: Image.asset('assets/images/disk.png'),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        '1. BigCity Boi',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      width: 200,
                      height: 70,
                      margin: EdgeInsets.only(top: 20),
                      child: FlatButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => GamePlay()));
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(70),
                            side: BorderSide(color: Colors.white, width: 3)),
                        child: Text(
                          'Play',
                          style: TextStyle(fontSize: 25, color: Colors.white),
                        ),
                        color: Colors.white24,
                      ),
                    ),
                  ]),
            )
          ],
        ),
      ),
    );
  }
}
