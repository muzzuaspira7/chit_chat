import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/colors/app_color.dart';
import 'package:chit_chat/helper/my_date_util.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:chit_chat/models/messsage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../screens/chat_screen.dart';
import 'dialog/profile_dialog.dart';

// card to represent a single user in home screen
class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last mesage info (if null --> no message)
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * .02, vertical: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColor.LightWhite,
      elevation: 0.5,
      child: InkWell(
          onTap: () {
            // for navigating to chat screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
              stream: APIs.getLastMessage(widget.user),
              builder: (context, snapshot) {
                final data = snapshot.data?.docs;
                final list =
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (list.isNotEmpty) _message = list[0];
                return ListTile(
                    // Getting this image from the user's gmail profile
                    leading: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => ProfileDialog(
                                  user: widget.user,
                                ));
                      },
                      child: CircleAvatar(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .8),
                          child: CachedNetworkImage(
                            height: mq.height * 0.55,
                            width: mq.height * 0.55,
                            imageUrl: widget.user.image,
                            errorWidget: (context, url, error) => CircleAvatar(
                              child: Icon(CupertinoIcons.person),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // User name
                    title: Text(widget.user.name),
                    // Last message
                    subtitle: Text(
                      _message != null
                          ? _message!.type == Type.image
                              ? 'image'
                              : _message!.msg
                          : widget.user.about,
                      maxLines: 1,
                    ),
                    // Last message time
                    trailing: _message == null
                        ? null //dont show anything when no message sent
                        : _message!.read.isEmpty &&
                                _message!.fromId != APIs.user.uid
                            ?
                            // show for unread message
                            Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    color: AppColor.DarkBlue),
                              )
                            :
                            // message sent time
                            Text(
                                MyDateUtil.getLastMessageTime(
                                    context: context, time: _message!.sent),
                                style: TextStyle(color: Colors.black54)));
              })),
    );
  }
}
