import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

class UserProfilePage extends StatefulWidget {
  final User user;
  UserProfilePage(this.user);
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  //File? avatar;
  final userNameController = TextEditingController();
  void initState() {
    initUser();
    super.initState();
  }

  void initUser() async {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    final UserProfile userProfile =
        await userProfileProvider.userProfile(widget.user.uid);
    userProfileProvider.load(userProfile);
    userNameController.text = userProfile.userName;
  }

  @override
  Widget build(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    return Column(
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: userProfileProvider.avatarURL != null
                  ? Image.network(userProfileProvider.avatarURL!,
                      width: 150, height: 150, fit: BoxFit.cover)
                  : Image.asset('assets/images/nus.png',
                      width: 150, height: 150, fit: BoxFit.cover),
            ),
            TextButton(
                onPressed: () async {
                  await userProfileProvider.uploadPic(context);
                },
                child: Text('Upload Avatar'))
          ],
        ),
        TextFormField(
          controller: userNameController,
          decoration: InputDecoration(labelText: 'userName'),
        ),
        TextButton(
            onPressed: userProfileProvider.saveChanges, child: Text('Save')),
      ],
    );
  }
}
