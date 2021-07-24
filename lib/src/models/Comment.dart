import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/models/Utils.dart';

class Comment {
  String postId;
  String commenterName;
  String commenterId;
  String? replyTo;
  String? replyToId;
  String text;
  DateTime timestamp;
  Post? post;

  Comment(
      {required this.postId,
      required this.commenterName,
      required this.commenterId,
      required this.text,
      required this.timestamp,
      this.replyTo,
      this.replyToId,
      this.post});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: json['postId'],
      commenterName: json['commenterName'],
      commenterId: json['commenterId'],
      replyTo: json['replyTo'],
      replyToId: json['replyToId'],
      text: json['text'],
      timestamp: Utils.toDateTime(json['timestamp']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'commenterName': commenterName,
      'commenterId': commenterId,
      'replyTo': replyTo,
      'replyToId': replyToId,
      'text': text,
      'timestamp': timestamp.toUtc(),
    };
  }
}
