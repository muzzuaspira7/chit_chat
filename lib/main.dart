import 'package:chit_chat/colors/app_color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'package:flutter_notification_channel/notification_importance.dart';

import 'package:flutter_notification_channel/flutter_notification_channel.dart';

// global object for accesing the device screen size
late Size mq;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  _initializeFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chit Chat',
      theme: ThemeData(
          inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColor.DarkBlue),
            ),

            labelStyle: TextStyle(color: AppColor.DarkBlue), // Label color
            hintStyle: TextStyle(color: AppColor.DarkBlue), // Hint text color
          ),
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: AppColor.IconColor, // Cursor color
            selectionColor: AppColor.IconColor, // Selection color
            selectionHandleColor: AppColor.IconColor, // Selection handle color
          ),
          fontFamily: 'MainFont',
          appBarTheme: AppBarTheme(
              backgroundColor: AppColor.DarkBlue,
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 1,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 21,
                // backgroundColor: Colors.white,
              ))),
      home: SplashScreen(),
    );
  }
}

_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  print('\nNotification Channel Result: $result');
}
