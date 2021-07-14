import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Circle/CirclePage.dart';
import 'package:keepin/pages/UserProfileDisplay.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:keepin/src/services/UserState.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  final User user;
  UserProfilePage(this.user);
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final double avatarSize = 80;
  String initialUserName = "";
  String initialBio = "";
  late Widget avatar;
  late Widget largeAvatar;
  bool loading = true;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void initUser(UserProfileProvider userProfileProvider) async {
    final UserProfile userProfile =
        await userProfileProvider.readUserProfile(widget.user.uid);
    userProfileProvider.load(userProfile);
    setState(() {
      initialUserName = userProfile.userName;
      initialBio = userProfile.bio == null
          ? "Please tell us more about you!"
          : userProfile.bio!;
      avatar = userProfileProvider.avatarURL == null
          ? defaultAvatar(avatarSize)
          : CachedNetworkImage(
              fit: BoxFit.cover,
              imageUrl: userProfileProvider.avatarURL!,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(value: downloadProgress.progress),
              errorWidget: (context, url, error) => Icon(Icons.error),
            );
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    UserState userState = Provider.of<UserState>(context, listen: false);
    CircleProvider circleProvider =
        Provider.of<CircleProvider>(context, listen: false);
    initUser(userProfileProvider);

    return loading
        ? Container()
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.teal.withAlpha(0x20),
                  // image: DecorationImage(
                  //   image: AssetImage('assets/images/blurry.jpg'),
                  //   fit: BoxFit.cover,
                  // ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UploadImageButton(
                      image: avatar,
                      size: avatarSize,
                      onPressed: () async {
                        await userProfileProvider.uploadPic(context);
                        userProfileProvider.saveChanges();
                      },
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0.0),
                        title: TextH2(initialUserName),
                        subtitle: TextH4(initialBio),
                        trailing: IconButton(
                          visualDensity:
                              VisualDensity(horizontal: -4.0, vertical: -4.0),
                          onPressed: () {
                            _showEditForm(context, userProfileProvider,
                                initialUserName, initialBio);
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextH3("Circles Joined: "),
                    StreamBuilder<List<CircleInfo>>(
                      stream: userProfileProvider.circlesJoined,
                      //stream: postProvider.posts,
                      builder: (context, snapshot) {
                        if (snapshot.data != null &&
                            snapshot.data!.isNotEmpty) {
                          return Container(
                            height: 60,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                CircleInfo data = snapshot.data![index];
                                return GestureDetector(
                                  onTap: () async {
                                    Circle circle = await circleProvider
                                        .readCircleFromName(data.circleName);
                                    Navigator.of(context).push(
                                        (MaterialPageRoute(
                                            builder: (context) => CirclePage(
                                                circle: circle,
                                                circleInfo: data))));
                                  },
                                  child: CircleInfoBuilder.buildCircleInfo(
                                      data.avatarURL,
                                      data.circleName,
                                      data.clockinCount),
                                );
                              },
                              separatorBuilder: (c, i) => VerticalDivider(
                                indent: 10,
                                endIndent: 10,
                                thickness: 1,
                              ),
                            ),
                          );
                        } else {
                          return Text('No circles joined');
                        }
                      },
                    ),
                  ],
                ),
              ),
              SecondaryButton(
                onPressed: userState.signOut,
                child: Text("Sign out"),
              ),
            ],
          );
  }

  Future<void> _showEditForm(BuildContext context, userProfileProvider,
      String initialUserName, String initialBio) async {
    return await showDialog(
      context: context,
      builder: (context) {
        final userNameController = TextEditingController();
        final bioController = TextEditingController();
        userNameController.text = initialUserName;
        bioController.text = initialBio;
        return AlertDialog(
          contentPadding: const EdgeInsets.all(20.0),
          actionsPadding:
              const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: userNameController,
                  validator: validator("User Name"),
                  decoration: InputDecoration(
                    labelText: 'User Name',
                  ),
                ),
                TextFormField(
                  controller: bioController,
                  validator: validator("Bio"),
                  decoration: InputDecoration(
                    labelText: 'Bio',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SecondaryButton(
                child: Text("cancel"), onPressed: Navigator.of(context).pop),
            PrimaryButton(
                child: Text("Save"),
                onPressed: () {
                  _formKey.currentState!.save();
                  if (_formKey.currentState!.validate()) {
                    userProfileProvider.changeUserName(userNameController.text);
                    userProfileProvider.changeBio(bioController.text);
                    userProfileProvider.saveChanges();
                    Navigator.of(context).pop();
                  }
                })
          ],
        );
      },
    );
  }

  String? Function(String?) validator(String field) {
    return (String? value) {
      return value == null || value.isEmpty ? "$field cannot be empty" : null;
    };
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
}
