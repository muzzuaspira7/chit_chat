import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/colors/app_color.dart';
import 'package:chit_chat/helper/my_date_util.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';

// Profile screen -- to show signed in user info
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // For hiding the keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          // Appbar
          appBar: AppBar(
            leading: BackButton(
              color: AppColor.IconColor,
            ),
            title: Text(
              widget.user.name,
              style: TextStyle(color: AppColor.IconColor),
            ),
          ),
          //FLoating button (to show the join date)
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Joined at: ',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
              Text(
                MyDateUtil.getLastMessageTime(
                    context: context,
                    time: widget.user.createdAt,
                    showYear: true),
                style: TextStyle(color: Colors.black54, fontSize: 16),
              )
            ],
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // for adding some space
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),

                  // User Profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      height: mq.height * .2,
                      width: mq.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                        child: Icon(CupertinoIcons.person),
                      ),
                    ),
                  ),
                  // for adding some space
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  // User Email
                  Text(
                    widget.user.email,
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  // for adding some space
                  SizedBox(
                    height: mq.height * .03,
                  ),

                  //  user about
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'About: ',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      Text(
                        widget.user.about,
                        style: TextStyle(color: Colors.black54, fontSize: 16),
                      )
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }
}
