import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:chit_chat/widgets/card_widget_for_view.dart';
import 'package:flutter/material.dart';

class ViewAllUsers extends StatefulWidget {
  const ViewAllUsers({super.key});

  @override
  State<ViewAllUsers> createState() => _ViewAllUsersState();
}

class _ViewAllUsersState extends State<ViewAllUsers> {
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // APP Bar
      // appBar: AppBar(
      //   backgroundColor: AppColor.DarkBlue,
      //   // leading: Icon(CupertinoIcons.home),
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
      //               if (i.name.toLowerCase().contains(val.toLowerCase()) ||
      //                   i.email.toLowerCase().contains(val.toLowerCase())) {
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
      //           style: TextStyle(fontFamily: 'MainFont'),
      //         ),
      //   actions: [
      //     // Search Icon
      //     IconButton(
      //         onPressed: () {
      //           setState(() {
      //             _isSearching = !_isSearching;
      //           });
      //         },
      //         icon: Icon(_isSearching
      //             ? CupertinoIcons.clear_circled_solid
      //             : Icons.search)),
      //     // More Feautures Icon
      //     // IconButton(
      //     //     onPressed: () {
      //     //       Navigator.push(
      //     //           context,
      //     //           MaterialPageRoute(
      //     //               builder: (_) => ProfileScreen(
      //     //                     user: APIs.me,
      //     //                   )));
      //     //     },
      //     //     icon: Icon(Icons.more_vert))
      //     // InkWell(
      //     //   child: CircleAvatar(
      //     //     backgroundImage: NetworkImage(APIs.me.image),
      //     //   ),
      //     //   onTap: () {
      //     //     Navigator.push(
      //     //         context,
      //     //         MaterialPageRoute(
      //     //             builder: (_) => ProfileScreen(
      //     //                   user: APIs.me,
      //     //                 )));
      //     //   },
      //     // ),

      //     SizedBox(
      //       width: 10,
      //     )
      //   ],
      // ),

      // body
      body: StreamBuilder(
        stream: APIs.viewAllUsers(),
        //get only those user, who's ids are provided
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            //if data is loading
            case ConnectionState.waiting:
            case ConnectionState.none:
            // return const Center(
            //     child: CircularProgressIndicator());

            //if some or all data is loaded then show it
            case ConnectionState.active:
            case ConnectionState.done:
              final data = snapshot.data?.docs;
              _list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              if (_list.isNotEmpty) {
                return ListView.builder(
                    itemCount: _isSearching ? _searchList.length : _list.length,
                    padding: EdgeInsets.only(top: mq.height * .01),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return cardWidgetforViewUsers(
                          user:
                              _isSearching ? _searchList[index] : _list[index]);
                    });
              } else {
                return const Center(
                  child: Text('No user found!', style: TextStyle(fontSize: 20)),
                );
              }
          }
        },
      ),
    );
  }
}
