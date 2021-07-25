import 'package:flutter/material.dart';
import 'package:keepin/src/models/UserProfile.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfile userProfile;

  const ProfileHeaderWidget({
    Key? key,
    required this.userProfile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
        height: 60,
        padding: EdgeInsets.all(16).copyWith(left: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BackButton(color: Colors.white),
            Expanded(
              child: Text(
                userProfile.userName,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 4),
          ],
        ),
      );
}
