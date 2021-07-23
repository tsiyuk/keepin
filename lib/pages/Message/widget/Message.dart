import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/Message.dart';
import 'package:keepin/src/models/UserProfile.dart';

class MessageWidget extends StatelessWidget {
  static Map<String, Image> map = Map<String, Image>();
  final Message message;
  final UserProfile userProfile;
  final bool isMe;
  const MessageWidget({
    Key? key,
    required this.message,
    required this.userProfile,
    required this.isMe,
  }) : super(key: key);



  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: isMe ? TextDirection.rtl : TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        isMe
            ? buildAvatar(FirebaseAuth.instance.currentUser!.photoURL)
            : buildAvatar(userProfile.avatarURL),
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(vertical: 6),
          constraints: BoxConstraints(maxWidth: 140),
          decoration: BoxDecoration(
            color: isMe
                ? Colors.grey[100]
                : Theme.of(context).primaryColorLight,
            borderRadius: isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() => Text(
    message.text,
    style: TextStyle(color: isMe ? Colors.black : Colors.white),
  );

  Widget buildAvatar(String? url) {
    if (url == null) {
      return defaultAvatar(40);
    } else {
      if (!map.containsKey(url)) {
        map.addEntries([
          MapEntry(
              url,
              Image.network(
                url,
                fit: BoxFit.cover,
              ))
        ]);
      }
      return Container(
        width: 60,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ImageButton(
          image: map[url]!,
          size: 40,
        ),
      );
    }
  }
}