class Message {
  String text;
  String userId;
  String? inviteCircleName;
  num timestamp;
  String time;

  Message({
    required this.text,
    required this.userId,
    this.inviteCircleName,
    required this.timestamp,
    required this.time,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
        text: json['text'],
        userId: json['userId'],
        timestamp: json['timestamp'],
        time: json['time'],
        inviteCircleName: json['inviteCircleName']);
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'userId': userId,
      'inviteCircleName': inviteCircleName,
      'time': time,
      'timestamp': timestamp,
    };
  }
}
