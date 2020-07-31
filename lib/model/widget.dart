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
