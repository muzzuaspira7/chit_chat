import 'package:chit_chat/colors/app_color.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:chit_chat/screens/profile_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api/apis.dart';
import '../widgets/chat_user_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched Items
  final List<ChatUser> _searchList = [];

  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getUserData();

    // for updating user actibve status according to lifecycle events
    // resume -- active or online
    // pause -- in active or offline

    SystemChannels.lifecycle.setMessageHandler((message) {
      print('Message: $message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }
      }

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        // for hiding kyboard on tap
        onTap: () => FocusScope.of(context).unfocus(),
        child: WillPopScope(
          // if search is on and back button is pressed then close search
          // or else simple close the current screen on back button click

          onWillPop: () {
            if (_isSearching) {
              setState(() {
                _isSearching = !_isSearching;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            // appBar: AppBar(
            //   backgroundColor: AppColor.DarkBlue,
            //   // leading: Icon(CupertinoIcons.home),
            //   elevation: 0,
            //   title: _isSearching
            //       ? TextField(
            //           decoration: InputDecoration(
            //             border: InputBorder.none,
            //             hintText: 'Search',
            //           ),
            //           autofocus: true,
            //           style: TextStyle(
            //             fontSize: 17,
            //             letterSpacing: 0.5,
            //           ),
            //           onChanged: (val) {
            //             // Search Logic
            //             _searchList.clear();

            //             for (var i in _list) {
            //               if (i.name
            //                       .toLowerCase()
            //                       .contains(val.toLowerCase()) ||
            //                   i.email
            //                       .toLowerCase()
            //                       .contains(val.toLowerCase())) {
            //                 _searchList.add(i);
            //               }
            //               setState(() {
            //                 _searchList;
            //               });
            //             }
            //           },
            //         )
            //       : Text(
            //           'Chatogram',
            //           style: TextStyle(
            //               fontFamily: 'MainFont', color: AppColor.LightWhite),
            //         ),
            //   actions: [
            //     // Search Icon
            //     IconButton(
            //         iconSize: 20,
            //         onPressed: () {
            //           setState(() {
            //             _isSearching = !_isSearching;
            //           });
            //         },
            //         icon: Icon(_isSearching
            //             ? CupertinoIcons.clear_circled_solid
            //             : Icons.search)),
            //     // More Feautures Icon

            //     InkWell(
            //       child: CircleAvatar(
            //         radius: 18,
            //         backgroundImage: NetworkImage(APIs.me.image),
            //       ),
            //       onTap: () {
            //         Navigator.push(
            //             context,
            //             MaterialPageRoute(
            //                 builder: (_) => ProfileScreen(
            //                       user: APIs.me,
            //                     )));
            //       },
            //     ),

            //     SizedBox(
            //       width: 10,
            //     )
            //   ],
            // ),
            body: StreamBuilder(
                stream: APIs.getMyUserId(),
                builder: ((context, snapshot) {
                  // get id if only known users
                  switch (snapshot.connectionState) {
                    //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());

                    //if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      return StreamBuilder(
                          stream: APIs.getAllUsers(
                              snapshot.data?.docs.map((e) => e.id).toList() ??
                                  []),
                          // get only those user, whos id are provided
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              // if data is loading
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                return Center(
                                  child: CircularProgressIndicator(),
                                  // child: Dialogs.showProgressBar(context),
                                );
                              // If some or all data is loaded then show it
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data!.docs;
                                _list = data
                                        ?.map(
                                            (e) => ChatUser.fromJson(e.data()))
                                        .toList() ??
                                    [];
                                // If else for chat user card
                                if (_list.isNotEmpty) {
                                  return ListView.builder(
                                      padding:
                                          EdgeInsets.only(top: mq.height * .01),
                                      physics: BouncingScrollPhysics(),
                                      itemCount: _isSearching
                                          ? _searchList.length
                                          : _list.length,
                                      itemBuilder: (context, index) {
                                        return ChatUserCard(
                                            user: _isSearching
                                                ? _searchList[index]
                                                : _list[index]);
                                        // return Text('Name: ${list[index]}');
                                      });
                                } else {
                                  return Center(
                                      child: Text(
                                    'No chat found',
                                    style: TextStyle(fontSize: 20),
                                  ));
                                }
                            }
                          });
                  }
                })),
          ),
        ));
  }
}
