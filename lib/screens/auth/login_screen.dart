// import 'dart:io';

import 'package:chit_chat/colors/app_color.dart';
import 'package:chit_chat/helper/dialogs.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/widgets/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../api/apis.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Animation for the login screen
  // By default it should be false
  bool _isAnimate = false;
  @override
  void initState() {
    super.initState();

    // for auto triggering animation
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        // Defining the animation as true
        _isAnimate = true;
      });
    });
  }

  _handlingGoogleBtnClick() {
    // To show the circular progress for the Login
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      // for hiding progress bar
      // Navigator.pop(context);

      if (user != null) {
        print('\nUser: ${user.user}');
        print('\nUserAdditionalInfo: ${user.additionalUserInfo}');

// To move to the homesreen (only if the user is login else it will show the login screen)
        if ((await APIs.userExists())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => TabBarWidget()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => TabBarWidget()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      print('\n_signInWithGoogle: $e');
      Dialogs.showSnackbar(context, 'Something went wrong (Check Interet)');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    //Initializing the mq here
    // mq = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColor.IconColor,
      body: Stack(
        children: [
          // App Logo
          AnimatedPositioned(
              duration: Duration(seconds: 2),
              top: mq.height * .25,
              right: _isAnimate ? mq.width * .25 : -mq.width * .5,
              width: mq.width * .5,
              child: Image.asset('assets/images/splashscreen.png')),
          // FOr the login button
          Positioned(
              bottom: mq.height * .15,
              left: mq.width * .05,
              width: mq.width * .9,
              height: mq.height * .06,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.DarkBlue,
                    shape: const StadiumBorder(),
                    elevation: 1),
                onPressed: () {
                  _handlingGoogleBtnClick();
                },
                // google icon
                icon: Image.asset(
                  'assets/images/google.png',
                  height: mq.height * .03,
                ),
                // login with google label
                label: RichText(
                    text: const TextSpan(
                        style: TextStyle(color: Colors.white, fontSize: 16),
                        children: [
                      TextSpan(text: 'Sign In with '),
                      TextSpan(
                          text: 'Google',
                          style: TextStyle(fontWeight: FontWeight.w500))
                    ])),
              )),
        ],
      ),
    );
  }
}
