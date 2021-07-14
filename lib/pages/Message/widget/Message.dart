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
      mainAxisAlignment:
          widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        widget.isMe
            ? buildAvatar(FirebaseAuth.instance.currentUser!.photoURL)
            : buildAvatar(widget.userProfile.avatarURL),
        Container(
          padding: EdgeInsets.all(16),
          margin: EdgeInsets.all(16),
          constraints: BoxConstraints(maxWidth: 140),
          decoration: BoxDecoration(
            color:
                widget.isMe ? Colors.grey[100] : Theme.of(context).accentColor,
            borderRadius: widget.isMe
                ? borderRadius.subtract(BorderRadius.only(bottomRight: radius))
                : borderRadius.subtract(BorderRadius.only(bottomLeft: radius)),
          ),
          child: buildMessage(),
        ),
      ],
    );
  }

  Widget buildMessage() => Column(
        crossAxisAlignment:
            widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.message.text,
            style: TextStyle(color: widget.isMe ? Colors.black : Colors.white),
            textAlign: widget.isMe ? TextAlign.end : TextAlign.start,
          ),
        ],
      );
  Widget buildAvatar(String? url) {
    if (url == null) {
      return defaultAvatar(16);
    } else {
      if (map.containsKey(url)) {
        return CircleAvatar(
          radius: 16,
          child: map[url]!,
        );
      } else {
        map.addEntries([MapEntry(url, Image.network(url))]);
        return CircleAvatar(
          radius: 16,
          child: map[url]!,
        );
      }
    }
  }
}
