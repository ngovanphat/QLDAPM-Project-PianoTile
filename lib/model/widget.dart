import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                padding: EdgeInsets.symmetric(horizontal: 20),
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

Widget userInRoom(BuildContext context, String username){
  return  Container(
    width: 150,
    height: 48,
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      color: Colors.grey[900],
      border: Border.all(
          color: Colors.white,
          width: 1.0
      ),
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

Widget customAlertDialog(BuildContext context, String text){
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
                child: new Text("Close", style: TextStyle( fontSize: 25),),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                        70),
                    side: BorderSide(
                        color:
                        Colors.white,
                        width: 3)),
              )
            ],
          ),
        ),
      ),
    ),
  );
}