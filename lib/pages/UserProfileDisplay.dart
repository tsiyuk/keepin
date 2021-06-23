import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/Loading.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:keepin/src/services/UserState.dart';
import 'package:provider/provider.dart';

// This widget is used to display other user's profile
class UserProfileDisplay extends StatefulWidget {
  final User user;
  UserProfileDisplay(this.user);
  @override
  _UserProfileDisplayState createState() => _UserProfileDisplayState();
}

class _UserProfileDisplayState extends State<UserProfileDisplay> {
  late String userName;
  late Image avatar;
  bool loading = true;

  void initUser(UserProfileProvider userProfileProvider) async {
    final UserProfile userProfile =
        await userProfileProvider.userProfile(widget.user.uid);
    userProfileProvider.load(userProfile);
    setState(() {
      userName = userProfile.userName;
      avatar = Image.network(userProfileProvider.avatarURL!,
          width: 100, height: 100, fit: BoxFit.cover);
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
                    ClipOval(
                      child: avatar,
                    ),
                    Column(
                      children: [Text(userName)],
                    )
                  ],
                ),
                StreamBuilder<List<CircleInfo>>(
                    stream: userProfileProvider.circlesJoined,
                    //stream: postProvider.posts,
                    builder: (context, snapshot) {
                      if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                        return SizedBox(
                          height: 300,
                          child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: Image.network(
                                      snapshot.data![index].avatarURL),
                                  title: Text(snapshot.data![index].circleName),
                                  subtitle: Text(
                                      'clockin days: ${snapshot.data![index].clockinCount}'),
                                  shape: Border.all(),
                                );
                              }),
                        );
                      } else {
                        return Text('No circles joined');
                      }
                    }),
              ],
            ),
          );
  }
}
