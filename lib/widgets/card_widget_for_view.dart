import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/colors/app_color.dart';
import 'package:chit_chat/helper/my_date_util.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:chit_chat/models/messsage.dart';
import 'package:chit_chat/screens/chat_screen.dart';
import 'package:chit_chat/widgets/dialog/profile_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ******************************* Contact list (All Usrs)****************************************

class cardWidgetforViewUsers extends StatefulWidget {
  final ChatUser user;
  const cardWidgetforViewUsers({super.key, required this.user});

  @override
  State<cardWidgetforViewUsers> createState() => _cardWidgetforViewUsersState();
}

class _cardWidgetforViewUsersState extends State<cardWidgetforViewUsers> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    final ChatUser userInfo = widget.user;

    return Card(
      elevation: 0.5,
      color: AppColor.LightWhite,
      child: InkWell(
        onTap: () {
          APIs.addChatUser(userInfo.email);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ChatScreen(
                      user: userInfo,
                    )),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(userInfo),
          builder: (context, snapShot) {
            if (snapShot.hasData && snapShot.data != null) {
              final data = snapShot.data!.docs;
              final list =
                  data.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (list.isNotEmpty) _message = list[0];
            }

            return ListTile(
              leading: InkWell(
                onTap: () => showDialog(
                    context: context,
                    builder: (_) => ProfileDialog(user: widget.user)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    height: mq.height * .055,
                    width: mq.height * .055,
                    imageUrl: userInfo.image,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
              ),
              title: Text(userInfo.name),
              subtitle: Text(
                _message != null
                    ? _message!.type == Type.image
                        ? 'image'
                        : _message!.msg
                    : userInfo.about,
                maxLines: 1,
              ),
              trailing: _message != null
                  ? _message!.read.isEmpty && _message!.fromId != APIs.user.uid
                      // Show for unread messages
                      ? Container(
                          height: 10,
                          width: 10,
                          decoration: BoxDecoration(
                              color: AppColor.DarkBlue,
                              borderRadius: BorderRadius.circular(10)),
                        )
                      // show sent message time
                      : Text(MyDateUtil.getLastMessageTime(
                          context: context, time: _message!.sent))
                  // Showing nothing when no messages sent
                  : null,
            );
          },
        ),
      ),
    );
  }
}
