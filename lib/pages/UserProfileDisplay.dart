import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

// This widget is used to display other user's profile
class UserProfileDisplay extends StatefulWidget {
  final User user;
  UserProfileDisplay(this.user);
  @override
  _UserProfileDisplayState createState() => _UserProfileDisplayState();
}

class _UserProfileDisplayState extends State<UserProfileDisplay> {
  final double avatarSize = 90;
  String userName = "";
  String bio = "";
  late Image avatar;
  bool loading = true;

  void initUser(UserProfileProvider userProfileProvider) async {
    final UserProfile userProfile =
        await userProfileProvider.userProfile(widget.user.uid);
    userProfileProvider.load(userProfile);
    setState(() {
      userName = userProfile.userName;
      bio = userProfile.bio == null
          ? "Please tell us more about you!"
          : userProfile.bio!;
      avatar = userProfileProvider.avatarURL == null
          ? Image.asset(
              'assets/images/placeholder.png',
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
            )
          : Image.network(
              userProfileProvider.avatarURL!,
              width: avatarSize,
              height: avatarSize,
              fit: BoxFit.cover,
              loadingBuilder: Loading.loadingBuilder,
            );
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    initUser(userProfileProvider);

    return loading
        ? Loading(100.0)
        : Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ClipOval(child: avatar),
                    SizedBox(width: 10),
                    ListTile(
                      contentPadding: const EdgeInsets.all(0.0),
                      title: TextH2(userName),
                      subtitle: TextH3(bio),
                    )
                  ],
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
                                  return CircleInfoBuilder.buildCircleInfo(
                                      data.avatarURL,
                                      data.circleName,
                                      data.clockinCount);
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
              ],
            ),
          );
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
