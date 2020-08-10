import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:piano_tile/model/widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Image.asset('assets/images/background.jpg', fit: BoxFit.cover),
              RowOnTop(context, 0, 0),
              Container(
                margin: EdgeInsets.only(top: 50),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: double.infinity,
                      height: 4,
                      color: const Color(0xff004466),
                    ),
                    Container(
                      width: double.infinity,
                      height: 90,
                      child: FlatButton(
                        onPressed: () {
                          _handleSignIn().whenComplete(() {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return Home();
                                },
                              ),
                            );
                          });
                        },
                        child: Row(
                          children: [
                            Image.asset('assets/images/google.png',
                                fit: BoxFit.cover),
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              width: 3,
                              height: double.infinity,
                              color: const Color(0xffff1a1a),
                            ),
                            Container(
                              width: 3,
                              height: double.infinity,
                              color: const Color(0xffffd11a),
                            ),

                            Container(
                              width: 3,
                              height: double.infinity,
                              color: const Color(0xff00e600),
                            ),
                            Container(
                              width: 3,
                              height: double.infinity,
                              color: const Color(0xff33ccff),
                            ),
                            Container(
                              width: 3,
                              height: double.infinity,
                              color: const Color(0xff0099cc),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "LOG IN GOOGLE TO:",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        "Play with friends",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        "Save your progress",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 5,
                      color: const Color(0xff004466),
                    ),
                    Container(
                      width: double.infinity,
                      height: 90,
                      child: FlatButton(
                        onPressed: () {},
                        child: Row(
                          children: [
                            Image.asset('assets/images/diamond.png',
                                fit: BoxFit.cover),
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              width: 5,
                              height: double.infinity,
                              color: const Color(0xffffffb3),
                            ),
                            Container(
                              width: 5,
                              height: double.infinity,
                              color: const Color(0xffffff80),
                            ),
                            Container(
                              width: 5,
                              height: double.infinity,
                              color: const Color(0xffffff4d),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "FREE DIAMONDS",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        "Get 5 free diamonds now",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 5,
                      color: const Color(0xff004466),
                    ),
                    Container(
                      width: double.infinity,
                      height: 90,
                      child: FlatButton(
                        onPressed: () {},
                        child: Row(
                          children: [
                            Image.asset('assets/images/friends.png',
                                fit: BoxFit.cover),
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              width: 5,
                              height: double.infinity,
                              color: const Color(0xff33ccff),
                            ),
                            Container(
                              width: 5,
                              height: double.infinity,
                              color: const Color(0xff0099cc),
                            ),
                            Container(
                              width: 5,
                              height: double.infinity,
                              color: const Color(0xff0086b3),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "FRIENDS LIST",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        "More friends more fun",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 5,
                      color: const Color(0xff004466),
                    ),
                    Container(
                      width: double.infinity,
                      height: 90,
                      child: FlatButton(
                        onPressed: () {},
                        child: Row(
                          children: [
                            Image.asset('assets/images/hearts.png',
                                fit: BoxFit.cover),
                            Container(
                              margin: EdgeInsets.only(left: 20),
                              width: 5,
                              height: double.infinity,
                              color: const Color(0xffff4d4d),
                            ),
                            Container(
                              width: 5,
                              height: double.infinity,
                              color: const Color(0xffff1a1a),
                            ),
                            Container(
                              width: 5,
                              height: double.infinity,
                              color: const Color(0xffe60000),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "FAVORITE SONGS",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                      Text(
                                        "Save the songs you love",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: 5,
                      color: const Color(0xff004466),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<FirebaseUser> _handleSignIn() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
  return user;
}

void signOutGoogle() async{
  await _googleSignIn.signOut();
}

