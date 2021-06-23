import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/UserProfile.dart';
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
  // final userNameController = TextEditingController();
  String initialUserName = "";
  String userName = "";
  late Image avatar;
  bool loading = true;

  void initUser(UserProfileProvider userProfileProvider) async {
    final UserProfile userProfile =
        await userProfileProvider.userProfile(widget.user.uid);
    userProfileProvider.load(userProfile);
    // userNameController.text = userProfile.userName;
    setState(() {
      initialUserName = userProfile.userName;
      avatar = Image.network(
        userProfileProvider.avatarURL!,
        width: 90,
        height: 90,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
      loading = false;
    });
  }

  void handleOnChange(String value) {
    setState(() {
      this.userName = value;
    });
    print(this.userName);
  }

  void handleSave(UserProfileProvider userProfileProvider) {
    print(this.userName);
    userProfileProvider.changeUserName(this.userName);
    userProfileProvider.saveChanges();
  }

  @override
  Widget build(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    UserState userState = Provider.of<UserState>(context, listen: false);
    initUser(userProfileProvider);

    return loading
        ? Container()
        : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              // decoration: BoxDecoration(
              //   image: DecorationImage(
              //     image: AssetImage('assets/images/blurry.jpg'),
              //     fit: BoxFit.cover,
              //   ),
              // ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      ClipOval(child: avatar),
                      Positioned(
                        right: -24,
                        bottom: -4,
                        child: MaterialButton(
                          onPressed: () async {
                            await userProfileProvider.uploadPic(context);
                            userProfileProvider.saveChanges();
                          },
                          color: Color(0xc0ffffff),
                          shape: CircleBorder(),
                          child: Icon(
                            Icons.upload_rounded,
                            size: 26,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: TextFormField(
                      initialValue: initialUserName,
                      onChanged: handleOnChange,
                      // controller: userNameController,
                      decoration: InputDecoration(
                        labelText: 'userName',
                        suffix: IconButton(
                          onPressed: () {
                            handleSave(userProfileProvider);
                          },
                          visualDensity: VisualDensity(vertical: -4.0),
                          icon: Icon(Icons.save),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              child: StreamBuilder<List<CircleInfo>>(
                stream: userProfileProvider.circlesJoined,
                //stream: postProvider.posts,
                builder: (context, snapshot) {
                  if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                    return SizedBox(
                      height: 60,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            CircleInfo data = snapshot.data![index];
                            return _buildCircleInfo(data.avatarURL, data.circleName, data.clockinCount);
                          },
                        separatorBuilder: (c, i) => VerticalDivider(indent: 10, endIndent: 10, thickness: 1,),
                      ),
                    );
                  } else {
                    return Text('No circles joined');
                  }
                },
              ),
            ),
            SecondaryButton(
              onPressed: userState.signOut,
              child: Text("Sign out"),
            ),
          ],
        );
  }

  Widget _buildCircleInfo(String url, String name, num count) {
    return Container(
      width: 130,
      height: 50,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(url, width: 40, height: 40, fit: BoxFit.cover,)
          ),
          SizedBox(width: 4),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontSize: 20),),
              Text('clockin days: $count', style: TextStyle(fontSize: 12),),
            ],
          )
        ],
      )
    );
  }

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
}
