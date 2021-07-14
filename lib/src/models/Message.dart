import 'Utils.dart';

class Message {
  String text;
  String userId;
  String receiverId;
  String? inviteCircleName;
  DateTime timestamp;

  Message({
    required this.text,
    required this.userId,
    this.inviteCircleName,
    required this.timestamp,
    required this.receiverId,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        text: json['text'],
        userId: json['userId'],
        receiverId: json['receiverId'],
        timestamp: Utils.toDateTime(json['timestamp']),
        inviteCircleName: json['inviteCircleName']);
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'userId': userId,
      'receiverId': receiverId,
      'inviteCircleName': inviteCircleName,
      'timestamp': timestamp.toUtc(),
    };
  }
}
