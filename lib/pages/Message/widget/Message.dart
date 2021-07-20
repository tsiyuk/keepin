import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/CommonWidgets.dart';
import 'package:keepin/src/models/Message.dart';
import 'package:keepin/src/models/UserProfile.dart';

class MessageWidget extends StatefulWidget {
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
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  Map<String, Image> map = Map<String, Image>();

  @override
  Widget build(BuildContext context) {
    final radius = Radius.circular(12);
    final borderRadius = BorderRadius.all(radius);

    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: widget.isMe ? TextDirection.rtl : TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        widget.isMe
            ? buildAvatar(FirebaseAuth.instance.currentUser!.photoURL)
            : buildAvatar(widget.userProfile.avatarURL),
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.symmetric(vertical: 6),
          constraints: BoxConstraints(maxWidth: 140),
          decoration: BoxDecoration(
            color: widget.isMe
                ? Colors.grey[100]
                : Theme.of(context).primaryColorLight,
            borderRadius: widget.isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() => Text(
        widget.message.text,
        style: TextStyle(color: widget.isMe ? Colors.black : Colors.white),
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
        child: ImageButton(
          image: map[url]!,
          size: 40,
        ),
      );
    }
  }
}
