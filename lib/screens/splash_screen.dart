import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/colors/app_color.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/screens/auth/login_screen.dart';
import 'package:chit_chat/widgets/tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Animation for the login screen
  // By default it should be false

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      // Exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));

      // If the user already login then it should not show the login page again
      // APIs.auth is coming from API folder(Im gonna use it multiple times)
      if (APIs.auth.currentUser != null) {
        print('\nUser: ${APIs.auth.currentUser}');

        // Navigate to home screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => TabBarWidget()));
      } else {
        // Navigate to Login screen
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //Initializing the mq here
    mq = MediaQuery.of(context).size;
    return Scaffold(
        body: Container(
      color: AppColor.SentColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              height: mq.height * 0.11,
              child:
                  Center(child: Image.asset('assets/images/splashscreen.png'))),
          SizedBox(
            height: 20,
          ),
          Text(
            'C H A T O G R A M',
            style: TextStyle(fontSize: 20),
          ),
          Column(
            children: [
              Text(
                'Created By Muzzu',
                style: TextStyle(fontSize: 10),
              )
            ],
          )
        ],
      ),
    ));
  }
}
