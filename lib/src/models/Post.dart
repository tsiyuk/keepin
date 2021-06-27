/*
  This class contains the information of the post: its poster, content, likes and comments
*/

class Post {
  // postId will be initialized when a document in firestore is created
  String? postId;
  String posterId;
  String posterName;
  String? posterAvatarLink;
  String circleName;
  String title;
  String text;
  List<String> imageLinks = [];
  num numOfLikes = 0;
  num timestamp;

  Post(
      {this.postId,
      required this.posterId,
      required this.posterName,
      this.posterAvatarLink,
      required this.circleName,
      required this.text,
      required this.title,
      required this.imageLinks,
      required this.numOfLikes,
      required this.timestamp});

  // factory method to retrive data from firestore
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'],
      posterId: json['posterId'],
      posterName: json['posterName'],
      posterAvatarLink: json['posterAvatarLink'],
      circleName: json['circleName'],
      text: json['text'],
      title: json['title'],
      imageLinks: List.castFrom(json['imageLinks']),
      numOfLikes: json['numOfLikes'],
      timestamp: json['timestamp'],
    );
  }

  // transform the Post into the json form
  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'posterId': posterId,
      'posterName': posterName,
      'posterAvatarLink': posterAvatarLink,
      'circleName': circleName,
      'text': text,
      'title': title,
      'imageLinks': imageLinks,
      'numOfLikes': numOfLikes,
      'timestamp': timestamp,
    };
  }
}
