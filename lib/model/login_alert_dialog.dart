import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/helper/sizes_helpers.dart';

class LoginDialog extends StatelessWidget {
@override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0))
    ),
      content: new Container(
        width: displayWidth(context)*0.8,
        height: displayHeight(context)*0.5,
        decoration: new BoxDecoration(
          color: const Color(0xFFFFFF),
        ),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            new Expanded(
              child: new Row(
                children: <Widget>[
                  new Container(
                    // padding: new EdgeInsets.all(10.0),
                    decoration: new BoxDecoration(
                      color: Colors.white,
                    ),
                    child: new Text(
                      'Login To Favorite This Song',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // dialog centre
            new Expanded(
              child: new Container(
                  child: new Text(
                    'Login To Favorite This Song',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                    textAlign: TextAlign.center,
                  ),),
              flex: 2,
            ),

            // dialog bottom
            new Expanded(
              child: new Container(
                padding: new EdgeInsets.all(16.0),
                decoration: new BoxDecoration(
                  color: const Color(0xFF33b17c),
                ),
                child: new Text(
                  'Continue to Login',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: 'helvetica_neue_light',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
