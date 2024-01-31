import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chit_chat/colors/app_color.dart';
import 'package:chit_chat/models/chat_user.dart';
import 'package:chit_chat/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import 'package:image_picker/image_picker.dart';

// Profile screen -- to show signed in user info
class ProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  // this one if for picking image
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // For hiding the keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          // Appbar
          appBar: AppBar(
            leading: BackButton(color: AppColor.IconColor),
            title: const Text(
              'Profile Screen',
              style: TextStyle(color: AppColor.IconColor),
            ),
          ),
          //FLoating button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: FloatingActionButton.extended(
              backgroundColor: AppColor.DarkBlue,
              onPressed: () async {
                Dialogs.showProgressBar(context);

                await APIs.updateActiveStatus(false);
                // sign out from app
                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    // For hiding progress dialog
                    Navigator.pop(context);

                    // // for moving to homescreen
                    // Navigator.pop(context);

                    APIs.auth = FirebaseAuth.instance;
                    // replacement home screen with login screen
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => LoginScreen()));
                  });
                });
              },
              label: Text(
                'Log out',
                style: TextStyle(color: Colors.white),
              ),
              icon: Icon(
                Icons.add_comment_rounded,
                color: AppColor.IconColor,
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // for adding some space
                    SizedBox(
                      width: mq.width,
                      height: mq.height * .03,
                    ),
                    // Using Stack because I wanna add edit button inside the image

                    // User Profile picture
                    Stack(
                      children: [
                        // profile picture
                        _image != null
                            ?
                            // Local Image
                            ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(
                                  File(_image!),
                                  height: mq.height * .2,
                                  width: mq.height * .2,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: CachedNetworkImage(
                                  height: mq.height * .2,
                                  width: mq.height * .2,
                                  fit: BoxFit.cover,
                                  imageUrl: widget.user.image,
                                  errorWidget: (context, url, error) =>
                                      const CircleAvatar(
                                    child: Icon(CupertinoIcons.person),
                                  ),
                                ),
                              ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            onPressed: () {
                              _showBottomSheet();
                            },
                            child: Icon(Icons.edit),
                            color: AppColor.DarkBlue,
                            shape: CircleBorder(),
                          ),
                        )
                      ],
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
                    // Name inputfield
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          CupertinoIcons.person,
                          color: AppColor.DarkBlue,
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Eg:- Muzzu',
                        label: const Text('Name'),
                      ),
                    ),
                    // for adding some space
                    SizedBox(
                      height: mq.height * .03,
                    ),
                    // About input field
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? '',
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                        prefixIcon: Icon(CupertinoIcons.person,
                            color: AppColor.DarkBlue),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'Eg:- Feeling Happy',
                        label: const Text('Name'),
                      ),
                    ),
                    // for adding some space
                    SizedBox(
                      height: mq.height * .03,
                    ),

                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.DarkBlue,
                        shape: StadiumBorder(),
                        minimumSize: Size(mq.width * .4, mq.height * .055),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          try {
                            await APIs.updateUserInfo();
                            Dialogs.showSnackbar(
                                context, 'Profile updated successfully');
                          } catch (error) {
                            print('Error updating user info: $error');
                            Dialogs.showSnackbar(
                                context, 'Failed to update profile');
                          }
                        }
                      },
                      icon: Icon(
                        Icons.edit,
                        color: AppColor.IconColor,
                      ),
                      label: Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )),
    );
  }

// bottom sheet for picking image for the user profile
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              Center(
                child: Container(
                  width: 150,
                  height: 2,
                  color: Colors.black38,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              // Pick profile picture lable
              const Text(
                'Pick Profile Picture',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              // FOr space
              SizedBox(
                height: mq.height * .02,
              ),
              // Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Pick from gallery button
                  Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: const CircleBorder(),
                              fixedSize: Size(mq.width * .2, mq.height * .15)),
                          onPressed: () async {
                            // Pick an image.
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera);
                            if (image != null) {
                              print('Image Path : ${image.path}');
                              setState(() {
                                _image = image.path;
                              });
                              APIs.updateProfilePicture(File(_image!));
                              Navigator.pop(context);
                            }
                          },
                          child: Image.asset('assets/images/photo-camera.png')),
                      Text('Camera')
                    ],
                  ),

                  // Take pictures from camera button
                  Column(
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: const CircleBorder(),
                              fixedSize: Size(mq.width * .2, mq.height * .15)),
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            // Pick an image.
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery);
                            if (image != null) {
                              print(
                                  'Image Path : ${image.path} -- MimeType: ${image.mimeType}');
                              setState(() {
                                _image = image.path;
                              });
                              APIs.updateProfilePicture(File(_image!));
                              Navigator.pop(context);
                            }
                          },
                          child: Image.asset('assets/images/image-galery.png')),
                      Text('Gallery')
                    ],
                  ),
                ],
              )
            ],
          );
        });
  }
}
