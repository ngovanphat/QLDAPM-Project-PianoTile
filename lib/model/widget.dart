import 'package:flutter/material.dart';

Widget PointRowTop(BuildContext context, int point, String image) {
  return Row(
    children: <Widget>[
      Container(
        padding: EdgeInsets.only(right: 6),
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Image.asset(
          '$image',
          width: 35,
          height: 35,
        ),
      ),
      Container(
          width: 60,
          alignment: Alignment.center,
          height: 30,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30), color: Colors.white60),
          child: Text(
            '$point',
            style: TextStyle(fontSize: 20),
          ))
    ],
  );
}
