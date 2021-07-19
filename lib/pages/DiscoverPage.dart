import 'package:flutter/material.dart';
import 'package:keepin/pages/TagSelector.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/services/UserProfileProvider.dart';
import 'package:provider/provider.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  @override
  Widget build(BuildContext context) {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    List<String> temp = userProfileProvider.tags;
    return Column(
      children: [
        TagSelector(texts: temp),
        PrimaryButton(
          child: Text('Save'),
          onPressed: () {
            userProfileProvider.changeTags(temp);
          },
        )
      ],
    );
  }

  void initUser(BuildContext context) async {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(context);
    final UserProfile userProfile =
        await userProfileProvider.readUserProfile(userProfileProvider.userId);
    userProfileProvider.load(userProfile);
  }
}
