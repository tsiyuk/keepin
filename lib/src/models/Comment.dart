class Comment {
  String postId;
  String commenterName;
  String commenterId;
  String? replyTo;
  String? replyToId;
  String text;
  num timestamp;
  String time;

  Comment(
      {required this.postId,
      required this.commenterName,
      required this.commenterId,
      required this.text,
      required this.timestamp,
      required this.time,
      this.replyTo,
      this.replyToId});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      postId: json['postId'],
      commenterName: json['commenterName'],
      commenterId: json['commenterId'],
      replyTo: json['replyTo'],
      replyToId: json['replyToId'],
      text: json['text'],
      timestamp: json['timestamp'],
      time: json['time'],
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
      'timestamp': timestamp,
    };
  }
}
