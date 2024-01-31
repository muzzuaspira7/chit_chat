import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/colors/app_color.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:chit_chat/models/messsage.dart';
import 'package:chit_chat/screens/view_profile_screen%20.dart';
import 'package:chit_chat/widgets/message_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // for storing all messages
  List<Message> _list = [];

  // for handling message changes
  final _textController = TextEditingController();

  // for storing value of showing or hiding emoji
  //  is uploading -- for checking  if image is uploading or not
  bool _showEmoji = false, _isUploading = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          // if emojis are shown & back button is pressed then hide emojies
          // or else simple current screeen on back button click

          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },

          child: Scaffold(
            // appbar
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            // body
            // backgroundColor: AppColor.LightWhite,
            body: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/chatbackground.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: StreamBuilder(
                          stream: APIs.getAllMessages(widget.user),
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              // if data is loading
                              case ConnectionState.waiting:
                              case ConnectionState.none:
                                return const Center(
                                  child: SizedBox(),
                                );
                              // If some or all data is loaded then show it
                              case ConnectionState.active:
                              case ConnectionState.done:
                                final data = snapshot.data!.docs;

                                _list = data
                                        ?.map((e) => Message.fromJson(e.data()))
                                        .toList() ??
                                    [];

                                // If else for chat user card
                                if (_list.isNotEmpty) {
                                  return ListView.builder(
                                      reverse: true,
                                      padding:
                                          EdgeInsets.only(top: mq.height * .01),
                                      physics: BouncingScrollPhysics(),
                                      itemCount: _list.length,
                                      itemBuilder: (context, index) {
                                        return MessageCard(
                                          message: _list[index],
                                        );
                                      });
                                } else {
                                  return Center(
                                      child: Text(
                                    'Say Hiiii 👋',
                                    style: TextStyle(
                                        fontSize: 20, color: AppColor.DarkBlue),
                                  ));
                                }
                            }
                          }),
                    ),
                    // progress indicator for showing uploading
                    if (_isUploading)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    _chatInput(),
                    // Show emoji on keyboard emoji click & vice versa
                    if (_showEmoji)
                      SizedBox(
                        height: mq.height * .30,
                        child: EmojiPicker(
                          textEditingController: _textController,
                          config: Config(
                            bgColor: AppColor.White,
                            columns: 8,
                            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                          ),
                        ),
                      )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// appbar widget
  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
          stream: APIs.getUserInfo(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

            return Row(
              children: [
                // Back Button
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColor.IconColor,
                    )),

                // user profile picture
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    width: mq.height * .05,
                    height: mq.height * .05,
                    imageUrl:
                        list.isNotEmpty ? list[0].image : widget.user.image,
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),

                // for adding some space
                SizedBox(
                  width: 10,
                ),

                // user name and last seen time
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // user name
                    Text(
                      list.isNotEmpty ? list[0].name : widget.user.name,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColor.IconColor),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    // Last seen time

                    Text(
                      list.isNotEmpty
                          ? list[0].isOnline
                              ? 'Online'
                              : MyDateUtil.getLastActiveTime(
                                  context: context,
                                  lastActive: list[0].lastActive)
                          : widget.user.lastActive,
                      style: TextStyle(fontSize: 14, color: AppColor.SentColor),
                    ),
                  ],
                )
              ],
            );
          },
        ));
  }

// bottom chat input field

  Widget _chatInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        children: [
          Expanded(
              child: Card(
            child: Row(children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      // TO hide Keyboard
                      FocusScope.of(context).unfocus();
                      // To show emoji
                      _showEmoji = !_showEmoji;
                    });
                  },
                  icon: Icon(
                    Icons.emoji_emotions,
                    color: AppColor.DarkBlue,
                    size: 26,
                  )),
              Expanded(
                  child: TextField(
                onTap: () {
                  if (_showEmoji) {
                    // TO hide emoj and show keyboard
                    setState(() {
                      _showEmoji = !_showEmoji;
                    });
                  }
                  ;
                },
                maxLines: 3,
                minLines: 1,
                controller: _textController,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Message...",
                    hintStyle: TextStyle(
                        color: const Color.fromARGB(255, 91, 157, 163))),
              )),
              IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Picking an Multiple images.
                    final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);
                    // sending one by one in firestore
                    for (var i in images) {
                      setState(() {
                        _isUploading = true;
                      });
                      await APIs.sendChatImage(widget.user, File(i.path));
                      setState(() {
                        _isUploading = false;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.image,
                    color: AppColor.DarkBlue,
                    size: 26,
                  )),
              IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick an image.
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.camera, imageQuality: 70);
                    if (image != null) {
                      setState(() {
                        _isUploading = true;
                      });
                      await APIs.sendChatImage(widget.user, File(image.path));
                      setState(() {
                        _isUploading = false;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    color: AppColor.DarkBlue,
                    size: 27,
                  ))
            ]),
          )),

          // Send Message Button
          MaterialButton(
            minWidth: 0,
            color: AppColor.DarkBlue,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if (_list.isEmpty) {
                  // on first message (add user to my_user collection of  chat user)
                  APIs.sendFirstMessage(
                      widget.user, _textController.text, Type.text);
                } else {
                  // simply send message

                  APIs.sendMessage(
                      widget.user, _textController.text, Type.text);
                  final ChatUser userInfo = widget.user;
                  APIs.addChatUser(userInfo.email);
                }

                _textController.text = '';
              }
            },
            child: Icon(Icons.send, color: AppColor.IconColor, size: 26),
          )
        ],
      ),
    );
  }
}
