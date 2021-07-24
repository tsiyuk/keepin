import 'Utils.dart';

class Message {
  String text;
  String userId;
  String receiverId;
  String? inviteCircleName;
  String? invitePostId;
  DateTime timestamp;

  Message({
    required this.text,
    required this.userId,
    this.inviteCircleName,
    this.invitePostId,
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
        invitePostId: json['invitePostId']);
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'userId': userId,
      'receiverId': receiverId,
      'inviteCircleName': inviteCircleName,
      'invitePostId': invitePostId,
      'timestamp': timestamp.toUtc(),
    };
  }
}
