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
  @override
  void initState() async {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    final UserProfile userProfile =
        await userProfileProvider.userProfile(widget.user.uid);
    userProfileProvider.load(userProfile);
    userNameController.text = userProfile.userName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    return Column(
      children: [
        Row(
          children: [
            userProfileProvider.avatarURL != null
                ? Image.network(userProfileProvider.avatarURL!)
                : Image.asset('asset/images/nus.png'),
            TextButton(
                onPressed: () async {
                  await userProfileProvider.uploadPic(context);
                },
                child: Text('Upload Avatar'))
          ],
        ),
        TextFormField(
          controller: userNameController,
          decoration: InputDecoration(labelText: 'email'),
        ),
        TextButton(
            onPressed: userProfileProvider.saveChanges, child: Text('Save')),
      ],
    );
  }
}
