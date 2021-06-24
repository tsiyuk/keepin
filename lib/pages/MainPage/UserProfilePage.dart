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
  final double avatarSize = 90;
  String initialUserName = "";
  String initialBio = "";
  late Image avatar;
  bool loading = true;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void initUser(UserProfileProvider userProfileProvider) async {
    final UserProfile userProfile =
        await userProfileProvider.userProfile(widget.user.uid);
    userProfileProvider.load(userProfile);
    setState(() {
      initialUserName = userProfile.userName;
      initialBio = userProfile.bio == null
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
              loadingBuilder: _loadingBuilder,
            );
      loading = false;
    });
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
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  // image: DecorationImage(
                  //   image: AssetImage('assets/images/blurry.jpg'),
                  //   fit: BoxFit.cover,
                  // ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      children: [
                        ClipOval(child: avatar),
                        Positioned(
                          right: -26,
                          bottom: -6,
                          child: MaterialButton(
                            onPressed: () async {
                              await userProfileProvider.uploadPic(context);
                              userProfileProvider.saveChanges();
                            },
                            color: Color(0xc0ffffff),
                            shape: CircleBorder(),
                            child: Icon(
                              Icons.upload_rounded,
                              size: 25,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(0.0),
                        title: TextH2(str: initialUserName),
                        subtitle: TextH3(str: initialBio),
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
              // Divider(thickness: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextH3(str: "Circles Joined: "),
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
                                return _buildCircleInfo(data.avatarURL,
                                    data.circleName, data.clockinCount);
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

  Widget _buildCircleInfo(String url, String name, num count) {
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

  Widget _loadingBuilder(
      BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return Center(
      child: CircularProgressIndicator(
        value: loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded /
                loadingProgress.expectedTotalBytes!
            : null,
      ),
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
          insetPadding: const EdgeInsets.all(20.0),
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
