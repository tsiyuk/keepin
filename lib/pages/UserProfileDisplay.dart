import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Message/ChatRoomPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/ChatRoom.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/ChatRoomProvider.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/PostProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

import 'Circle/CirclePage.dart';
import 'Post/PostPage.dart';

// This widget is used to display other user's profile
class UserProfileDisplay extends StatefulWidget {
  final String userId;
  UserProfileDisplay(this.userId);
  @override
  _UserProfileDisplayState createState() => _UserProfileDisplayState();
}

class _UserProfileDisplayState extends State<UserProfileDisplay> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile>(
        future: UserProfileProvider.readUserProfileOnce(widget.userId),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Loading(30)
                : Helper(userProfile: snapshot.data!));
  }
}

class Helper extends StatefulWidget {
  final UserProfile userProfile;
  const Helper({Key? key, required this.userProfile}) : super(key: key);

  @override
  _HelperState createState() => _HelperState();
}

class _HelperState extends State<Helper> {
  final double avatarSize = 90;
  String userName = "";
  String bio = "";
  late Widget avatar;
  bool loading = true;
  late final Stream<List<Post>> userPosts;

  @override
  void initState() {
    userName = widget.userProfile.userName;
    bio = widget.userProfile.bio == null
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
    loading = false;
    userPosts = PostProvider.readPostsFromUser(widget.userProfile.userId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    CircleProvider circleProvider =
        Provider.of<CircleProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(),
      body: loading
          ? Loading(100.0)
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.teal.withAlpha(0x20),
                    ),
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ImageButton(image: avatar, size: avatarSize),
                        SizedBox(width: 10),
                        Expanded(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(0.0),
                            title: TextH2(userName),
                            subtitle: TextH4(bio),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    // 140 profile height, 56 app bar, 32 margin, 70 button
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height - 340),
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: MediaQuery.of(context).size.width),
                          TextH3("Circles Joined: "),
                          StreamBuilder<List<CircleInfo>>(
                            stream: UserProfileProvider.readCircleJoined(
                                widget.userProfile.userId),
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
                                          circleProvider
                                              .addCircleHistory(circle);
                                          Navigator.of(context).push(
                                              (MaterialPageRoute(
                                                  builder: (context) =>
                                                      CirclePage(
                                                          circle: circle,
                                                          circleInfo: data))));
                                        },
                                        child:
                                            CircleInfoBuilder.buildCircleInfo(
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
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6.0),
                            child: TextH3("My Interest Tags: "),
                          ),
                          Wrap(
                            children: widget.userProfile.tags.isNotEmpty
                                ? widget.userProfile.tags.map((tag) {
                                    return Chip(label: Text(tag));
                                  }).toList()
                                : [Text("No interest tags")],
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
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(6),
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
                                          onTap: () => Navigator.of(context)
                                              .push(MaterialPageRoute(
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
                        ],
                      ),
                    ),
                  ),
                  if (widget.userProfile.userId !=
                      FirebaseAuth.instance.currentUser!.uid)
                    PrimaryButton(
                        child: Text('Contact'),
                        onPressed: () async {
                          ChatRoom chatRoom =
                              await ChatRoomAPI.getOrCreateChatRoom(
                                  FirebaseAuth.instance.currentUser!.uid,
                                  widget.userProfile.userId);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ChatRoomPage(chatRoom: chatRoom)));
                        })
                  else
                    Container(),
                ],
              ),
            ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
