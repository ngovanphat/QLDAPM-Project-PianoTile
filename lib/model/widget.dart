import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:piano_tile/views/gem_shop.dart';

Widget PointRowTop(BuildContext context, int point, String image) {
  return Row(
    children: <Widget>[
      Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Image.asset(
                '$image',
                width: 35,
                height: 35,
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                child: Text(
                  '$point',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ))
          ],
        ),
      ),
    ],
  );
}

Widget PointRowTop_plusButton(BuildContext context, int point, String image) {
  return Row(
    children: <Widget>[
      Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Image.asset(
                '$image',
                width: 35,
                height: 35,
              ),
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                child: Text(
                  '$point',
                  style: TextStyle(fontSize: 20, color: Colors.black),
                )),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GemShop()));
              }, // handle your image tap here
              child: Image.asset(
                'assets/images/plus.png',
                width: 20,
                height: 20,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget PointRowTop_percentBar(
    BuildContext context, int exp, int nextExp, String image) {
  return Row(
    children: <Widget>[
      Container(
        width: 200,
        height: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.white),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Image.asset(
                '$image',
                width: 35,
                height: 35,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              child: new LinearPercentIndicator(
                width: 140,
                animation: true,
                lineHeight: 20.0,
                animationDuration: 2000,
                percent: exp / nextExp,
                center: Text('$exp/$nextExp'),
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: Colors.lightBlue,
              ),
            )
          ],
        ),
      ),
    ],
  );
}

Widget RowOnTop(BuildContext context, int level, int gems) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        PointRowTop(context, level, 'assets/images/one.png'),
        PointRowTop(context, gems, 'assets/images/gems.png'),
      ],
    ),
  );
}

Widget RowOnTop_v2(
    BuildContext context, int level, int gems, int currentExp, int nextExp) {
  Map<int, String> mapLevelImage = {
    1: 'assets/images/one.png',
    2: 'assets/images/two.png',
    3: 'assets/images/three.png',
    4: 'assets/images/four.png',
    5: 'assets/images/five.png',
  };

  return Container(
    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        PointRowTop_percentBar(
            context, currentExp, nextExp, mapLevelImage[level]),
        PointRowTop_plusButton(context, gems, 'assets/images/gems.png'),
      ],
    ),
  );
}

Widget userInRoom(BuildContext context, String username) {
  return Container(
    width: 150,
    height: 48,
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      color: Colors.grey[900],
      border: Border.all(color: Colors.white, width: 1.0),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Center(
      child: Text(
        '$username',
        style: TextStyle(
          fontSize: 22,
          color: Colors.white,
        ),
      ),
    ),
  );
}

Widget customAlertDialog(BuildContext context, String text) {
  return Material(
    type: MaterialType.transparency,
    child: FractionallySizedBox(
      heightFactor: 0.3,
      widthFactor: 0.7,
      child: Container(
        padding: new EdgeInsets.all(25.0),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  '$text',
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
              FlatButton(
                color: Colors.blueAccent,
                child: new Text(
                  "Close",
                  style: TextStyle(fontSize: 25),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(70),
                    side: BorderSide(color: Colors.white, width: 3)),
              )
            ],
          ),
        ),
      ),
    ),
  );
}
