import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepin/pages/Message/ChatRoomPage.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/ChatRoom.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/ChatRoomProvider.dart';
import 'package:keepin/src/services/CircleProvider.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

import 'Circle/CirclePage.dart';

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
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    return FutureBuilder<UserProfile>(
        future: userProfileProvider.readUserProfile(widget.userId),
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    CircleProvider circleProvider =
        Provider.of<CircleProvider>(context, listen: false);
    ChatRoomProvider chatRoomProvider = Provider.of<ChatRoomProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: loading
          ? Loading(100.0)
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.teal.withAlpha(0x20),
                    ),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextH3("Circles Joined: "),
                        StreamBuilder<List<CircleInfo>>(
                          stream: userProfileProvider
                              .readCircleJoined(widget.userProfile.userId),
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
                      ],
                    ),
                  ),
                  if (widget.userProfile.userId !=
                      FirebaseAuth.instance.currentUser!.uid)
                    PrimaryButton(
                        child: Text('Contact'),
                        onPressed: () async {
                          ChatRoom chatRoom;
                          chatRoomProvider
                              .setNewUser(widget.userProfile.userId);
                          var temp = await chatRoomProvider.specifiedChatRoom;
                          if (temp.isEmpty) {
                            chatRoom = await chatRoomProvider.createChatRoom();
                          } else {
                            chatRoom = temp[0];
                          }
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
}

class CircleInfoBuilder {
  static Widget buildCircleInfo(String url, String name, num count) {
    return Container(
      width: 130,
      height: 50,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              url,
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 4),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                child: Text(
                  name,
                  style: TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'keepin for: $count',
                style: TextStyle(fontSize: 12),
              ),
            ],
          )
        ],
      ),
    );
  }
}
