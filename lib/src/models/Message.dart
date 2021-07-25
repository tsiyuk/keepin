import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Post.dart';

import 'Utils.dart';

class Message {
  String text;
  String userId;
  String receiverId;
  String? inviteCircleName;
  DateTime timestamp;
  String? postId;
  Circle? circle;
  Post? post;

  Message({
    required this.text,
    required this.userId,
    this.inviteCircleName,
    this.postId,
    required this.timestamp,
    required this.receiverId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        text: json['text'],
        userId: json['userId'],
        receiverId: json['receiverId'],
        timestamp: Utils.toDateTime(json['timestamp']),
        inviteCircleName: json['inviteCircleName'],
        postId: json['postId']);
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'userId': userId,
      'receiverId': receiverId,
      'inviteCircleName': inviteCircleName,
      'postId': postId,
      'timestamp': timestamp.toUtc(),
    };
  }
}
