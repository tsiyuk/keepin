import 'package:keepin/src/models/Message.dart';

class ChatRoom {
  String uid;
  List<String> userIds;
  Message? latestMessage;
  List<bool> unread;

  ChatRoom({
    required this.userIds,
    required this.uid,
    this.latestMessage,
    required this.unread,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
        uid: json['uid'],
        userIds: List.castFrom(json['userIds']),
        latestMessage: json['latestMessage'] != null
            ? Message.fromJson(json['latestMessage'])
            : null,
        unread: List.castFrom(json['unread']));
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userIds': userIds,
      'latestMessage': latestMessage != null ? latestMessage?.toMap() : null,
      'unread': unread,
    };
  }
}
