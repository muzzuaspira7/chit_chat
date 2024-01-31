import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/colors/app_color.dart';
import 'package:chit_chat/main.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:chit_chat/screens/view_profile_screen%20.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({super.key, required this.user});

  final ChatUser user;

  @override
  Widget build(BuildContext context) {
    return

//     AlertDialog(
//       backgroundColor: Colors.white.withOpacity(.9),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       content: SizedBox(
//         width: mq.width * .6,
//         height: mq.height * .35,
//         child: Stack(
//           children: [
//             // user profile picture
//             Positioned(
//               top: mq.height * .075,
//               left: mq.width * .05,
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(mq.height * .25),
//                 child: CachedNetworkImage(
//                   width: mq.width * .5,
//                   fit: BoxFit.cover,
//                   imageUrl: user.image,
//                   errorWidget: (context, url, error) => const CircleAvatar(
//                     child: Icon(CupertinoIcons.person),
//                   ),
//                 ),
//               ),
//             ),
//             // user name
//             Positioned(
//               left: mq.width * .04,
//               top: mq.height * .02,
//               width: mq.width * .55,
//               child: Text(
//                 user.name,
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//             ),
// // info button
//             Positioned(
//               right: 8,
//               top: 6,
//               child: MaterialButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 minWidth: 0,
//                 shape: CircleBorder(),
//                 child: Icon(
//                   Icons.info_outline,
//                   color: AppColor.DarkBlue,
//                   size: 30,
//                 ),
//                 padding: EdgeInsets.all(0),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
        AlertDialog(
      backgroundColor: AppColor.LightWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .3,
        child: Stack(
          children: [
            //User Name
            Positioned(
              width: mq.width * .55,
              child: Text(
                user.name,
                style: TextStyle(fontSize: 19),
              ),
            ),

            // User Image
            Positioned(
              top: mq.height * .06,
              left: mq.width * .06,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .11),
                child: CachedNetworkImage(
                  width: mq.height * .22,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) => const CircleAvatar(
                    child: Icon(CupertinoIcons.person),
                  ),
                ),
              ),
            ),

            // More Icon
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => {
                  Navigator.pop(context),
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ViewProfileScreen(user: user))),
                },
                child: Icon(
                  Icons.info_outline,
                  size: 26,
                  color: AppColor.DarkBlue,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
