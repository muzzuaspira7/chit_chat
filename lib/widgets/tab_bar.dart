import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/colors/app_color.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:chit_chat/screens/home_screen.dart';
import 'package:chit_chat/screens/profile_screen.dart';
import 'package:chit_chat/screens/view_all_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabBarWidget extends StatefulWidget {
  const TabBarWidget({super.key});

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget> {
  // for storing all users
  List<ChatUser> _list = [];

  // for storing searched Items
  final List<ChatUser> _searchList = [];

  // for storing search status
  bool _isSearching = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          body: DefaultTabController(
              length: 2,
              child: Scaffold(
                backgroundColor: AppColor.DarkBlue,
                appBar: AppBar(
                  backgroundColor: AppColor.DarkBlue,
                  // leading: Icon(CupertinoIcons.home),
                  elevation: 0,
                  title: _isSearching
                      ? TextField(
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '  Search',
                              hintStyle: TextStyle(color: AppColor.SentColor)),
                          autofocus: true,
                          style: TextStyle(
                            fontSize: 17,
                            letterSpacing: 0.5,
                          ),
                          onChanged: (val) {
                            // Search Logic
                            _searchList.clear();

                            for (var i in _list) {
                              if (i.name
                                      .toLowerCase()
                                      .contains(val.toLowerCase()) ||
                                  i.email
                                      .toLowerCase()
                                      .contains(val.toLowerCase())) {
                                _searchList.add(i);
                              }
                              setState(() {
                                _searchList;
                              });
                            }
                          },
                        )
                      : Text(
                          'Chatogram',
                          style: TextStyle(
                              fontFamily: 'MainFont',
                              color: AppColor.LightWhite),
                        ),
                  actions: [
                    // Search Icon
                    IconButton(
                        iconSize: 20,
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                          });
                        },
                        icon: Icon(_isSearching
                            ? CupertinoIcons.clear_circled_solid
                            : Icons.search)),
                    // More Feautures Icon

                    InkWell(
                      child: CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 106, 250, 255),
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(APIs.me.image),
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ProfileScreen(
                                      user: APIs.me,
                                    )));
                      },
                    ),

                    SizedBox(
                      width: 10,
                    )
                  ],
                ),
                body: Column(
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    TabBar(
                        dividerColor: AppColor.IconColor,
                        indicatorColor: AppColor.DarkBlue,
                        labelColor: AppColor.LightWhite,
                        // unselectedLabelColor: AppColor.SentColor,
                        tabs: [
                          // Icon(
                          //   Icons.home,
                          //   color: AppColor.DarkBlue,
                          // ),
                          Text(
                            'C H A T S',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'C O N T A C T S',
                            style: TextStyle(fontSize: 16),
                          )
                        ]),
                    Expanded(
                      child: TabBarView(children: [
                        HomeScreen(),
                        ViewAllUsers(),
                      ]),
                    )
                  ],
                ),
              )),
        ),
      ),
    );
  }
}
