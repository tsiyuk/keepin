import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Circle/CirclePage.dart';
import 'package:keepin/pages/Post/PostPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:keepin/src/services/UserState.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  final UserProfile userProfile;
  UserProfilePage(this.userProfile);
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final double avatarSize = 80;
  String initialUserName = "";
  String initialBio = "";
  late Widget avatar;
  late Widget largeAvatar;
  bool loading = false;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final Stream<List<Post>> userPosts;

  @override
  void initState() {
    super.initState();
    userPosts = PostProvider.readPostsFromUser(widget.userProfile.userId);
    initialUserName = widget.userProfile.userName;
    initialBio = widget.userProfile.bio == null
        ? "Please tell us more about you!"
        : widget.userProfile.bio!;
    avatar = widget.userProfile.avatarURL == null
        ? defaultAvatar(avatarSize)
        : CachedNetworkImage(
            fit: BoxFit.cover,
            imageUrl: widget.userProfile.avatarURL!,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, error) => Icon(Icons.error),
          );
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    CircleProvider circleProvider =
        Provider.of<CircleProvider>(context, listen: false);

    return loading
        ? Container()
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 130,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.teal.withAlpha(0x20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UploadImageButton(
                      image: avatar,
                      size: avatarSize,
                      onPressed: () async {
                        String avatarURL =
                            await UserProfileProvider.uploadPic(context);
                        UserProfileProvider.updateAvatarURL(avatarURL);
                      },
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0.0),
                        title: TextH2(initialUserName),
                        subtitle: TextH4(initialBio),
                        trailing: IconButton(
                          onPressed: () {
                            _showEditForm(context, widget.userProfile,
                                initialUserName, initialBio);
                          },
                          icon: Icon(Icons.edit),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                // 130 profile height, 56 app bar, 92 bottom bar
                height: MediaQuery.of(context).size.height - 280,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextH3("Circles Joined: "),
                        StreamBuilder<List<CircleInfo>>(
                          stream: UserProfileProvider.circlesJoined,
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
                                        Circle circle = await CircleProvider
                                            .readCircleFromName(
                                                data.circleName);
                                        circleProvider.addCircleHistory(circle);
                                        Navigator.of(context).push(
                                            (MaterialPageRoute(
                                                builder: (context) =>
                                                    CirclePage(
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
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: TextH3("My Interest Tags: "),
                        ),
                        Wrap(
                          children: widget.userProfile.tags.isNotEmpty
                              ? widget.userProfile.tags.map((tag) {
                                  return Chip(label: Text(tag));
                                }).toList()
                              : [
                                  Text(
                                      "Please add your favourite tags on the top right corner.")
                                ],
                        ),
                        SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: TextH3("My Posts: "),
                        ),
                        StreamBuilder<List<Post>>(
                          stream: userPosts,
                          builder: (context, snapshot) {
                            if (snapshot.data != null &&
                                snapshot.data!.isNotEmpty) {
                              return ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    Post post = snapshot.data![index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(1, 3),
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        title: TextH3(post.title),
                                        subtitle: getTimeDisplay(
                                            post.timestamp.toString()),
                                        trailing: Text(post.circleName),
                                        onTap: () => Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PostPage(post: post))),
                                      ),
                                    );
                                  });
                            } else {
                              return Text('No Post');
                            }
                          },
                        ),
                        Center(
                          child: SecondaryButton(
                            onPressed: () {
                              userState.signOut();
                              dispose();
                            },
                            child: Text("Sign out"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  Future<void> _showEditForm(BuildContext context, UserProfile userProfile,
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
                  autofocus: true,
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
                    UserProfileProvider.saveChanges(
                        userNameController.text,
                        userProfile.tags,
                        userProfile.avatarURL,
                        bioController.text);
                    setState(() {
                      initialUserName = userNameController.text;
                      initialBio = bioController.text;
                    });
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
}
