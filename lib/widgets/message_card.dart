import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/api/apis.dart';
import 'package:chit_chat/colors/app_color.dart';
import 'package:chit_chat/helper/dialogs.dart';
import 'package:chit_chat/helper/my_date_util.dart';
import 'package:chit_chat/models/messsage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';

import '../main.dart';

// for showing single message details
class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;

    return InkWell(
      onLongPress: () {
        _showBottomSheet(isMe);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  // sender or another user message
  Widget _blueMessage() {
    // update last read message if the sender and the reciever are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
      print('Updated succesfully');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // to show message
            Flexible(
                child: Container(
              constraints: BoxConstraints(maxWidth: 300.0),
              padding: EdgeInsets.all(widget.message.type == Type.image
                  ? mq.width * .01
                  : mq.width * .015),
              margin: EdgeInsets.only(
                  top: mq.height * .01,
                  left: mq.width * .04,
                  right: mq.width * .04),
              decoration: BoxDecoration(
                  color: AppColor.ReciveColor,
                  border: Border.all(color: AppColor.IconColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: widget.message.type == Type.text
                  ? Text(
                      widget.message.msg + "",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    )
                  : SizedBox(
                      width: 300,
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.blueAccent,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image,
                            size: 70,
                          ),
                        ),
                      ),
                    ),
            )),
            SizedBox(
              width: mq.width * .15,
            )
          ],
        ),
        // To show date
        Container(
          margin: EdgeInsets.only(
            bottom: mq.height * .01,
            left: mq.width * .04,
          ),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: TextStyle(fontSize: 12, color: Colors.black26),
          ),
        )
      ],
    );
  }

  // our or user message
  Widget _greenMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // to show message
            Flexible(
                child: Container(
              constraints: BoxConstraints(maxWidth: 300.0),
              padding: EdgeInsets.all(widget.message.type == Type.image
                  ? mq.width * .00
                  : mq.width * .015),
              margin: EdgeInsets.only(
                  top: mq.height * .01,
                  left: mq.width * .04,
                  right: mq.width * .04),
              decoration: BoxDecoration(
                  color: AppColor.SentColor,
                  border: Border.all(color: AppColor.IconColor),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(10))),
              child: widget.message.type == Type.text
                  ? Text(
                      widget.message.msg + "",
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    )
                  : SizedBox(
                      // height: 500,
                      width: 300,
                      child: ClipRRect(
                        child: CachedNetworkImage(
                          imageUrl: widget.message.msg,
                          placeholder: (context, url) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.blueAccent,
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.image,
                            size: 70,
                          ),
                        ),
                      ),
                    ),
            )),
          ],
        ),

        //  Show Time and read status
        Container(
          margin: EdgeInsets.only(
            bottom: mq.height * .01,
            right: mq.width * .04,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              widget.message.read.isNotEmpty
                  ? Icon(
                      Icons.done_all_rounded,
                      size: 20,
                      color: Colors.blue,
                    )
                  : const Icon(
                      Icons.done,
                      size: 20,
                    ),
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.message.sent),
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        )
      ],
    );
  }

  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.message.type == Type.text
                  // Copy option
                  ? _OptionItem(
                      icon: Icon(
                        Icons.copy,
                        color: AppColor.DarkBlue,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) => Navigator.pop(context));

                        Dialogs.showSnackbar(context, 'Text Copied');
                      })
                  // download option
                  : _OptionItem(
                      icon: Icon(
                        Icons.download,
                        color: AppColor.DarkBlue,
                      ),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          print('Image Url: ${widget.message.msg}');

                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'Chatogram')
                              .then((success) {
                            Navigator.pop(context);
                            Dialogs.showSnackbar(
                                context, 'Image Successfully Saved!');
                          });
                        } catch (e) {
                          print('ErrorWhileSavingImage: $e');
                        }
                      }),
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: Icon(
                      Icons.edit,
                      color: AppColor.DarkBlue,
                    ),
                    name: 'Edit Message',
                    onTap: () {
                      _showMessageUpdateDialog();
                    }),
              if (isMe)
// Delete option
                _OptionItem(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    name: 'Delete Message',
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        // for hiding sheet
                        Navigator.pop(context);
                      });
                    }),

              // Sent time

              _OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: AppColor.DarkBlue,
                  ),
                  name:
                      'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),

              // read at

              _OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.red,
                  ),
                  name: widget.message.read.isEmpty
                      ? 'Read At: Not seen yet!'
                      : 'Read at:  ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),
            ],
          );
        });
  }

  // dialog for updating message
  void _showMessageUpdateDialog() {
    String updatedMsg = widget.message.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding:
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              // title
              title: Row(
                children: [
                  Icon(
                    Icons.message,
                    color: AppColor.DarkBlue,
                    size: 27,
                  ),
                  Text(' Update Message')
                ],
              ),
              // Content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                initialValue: updatedMsg,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),
              // actions
              actions: [
                // cancle button
                MaterialButton(
                  onPressed: () {
                    // hide alert dialog
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancle',
                    style: TextStyle(color: AppColor.DarkBlue, fontSize: 16),
                  ),
                ),
                // Update button
                MaterialButton(
                  onPressed: () {
                    // hide alert dialog
                    Navigator.pop(context);
                    APIs.updateMessage(widget.message, updatedMsg);
                  },
                  child: Text(
                    'Update',
                    style: TextStyle(color: AppColor.DarkBlue, fontSize: 16),
                  ),
                ),
              ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * .05,
            top: mq.height * .015,
            bottom: mq.height * .015),
        child: Row(
          children: [icon, Flexible(child: Text('      $name'))],
        ),
      ),
    );
  }
}
