class Circle {
  String circleName;
  String avatarURL;
  List<String> tags = [];
  bool isPublic;
  String adminUserId;
  num numOfMembers;
  String? description;
  List<String>? descriptionImageURLs = [];

  Circle({
    required this.circleName,
    required this.avatarURL,
    required this.tags,
    required this.isPublic,
    required this.adminUserId,
    required this.numOfMembers,
    this.description,
    this.descriptionImageURLs,
  });

  // factory method to retrive data from firestore
  factory Circle.fromJson(Map<String, dynamic> json) {
    return Circle(
        circleName: json['circleName'],
        avatarURL: json['avatarURL'],
        tags: List.castFrom(json['tags']),
        isPublic: json['isPublic'],
        adminUserId: json['adminUserId'],
        numOfMembers: json['numOfMembers'],
        description: json['descritpyion'],
        descriptionImageURLs: json['descriptionImageURLs']);
  }

  // transform the Circle into the json form
  Map<String, dynamic> toMap() {
    return {
      'circleName': circleName,
      'avatarURL': avatarURL,
      'tags': tags,
      'isPublic': isPublic,
      'adminUserId': adminUserId,
      'numOfMembers': numOfMembers,
      'description': description,
      'descriptionImageURLs': descriptionImageURLs,
    };
  }
}

class CircleInfo {
  String circleName;
  String avatarURL;
  num clockinCount;

  CircleInfo(this.circleName, this.avatarURL, this.clockinCount);

  factory CircleInfo.fromJson(Map<String, dynamic> json) {
    return CircleInfo(
        json['circleName'], json['avatarURL'], json['clockinCount']);
  }

  Map<String, dynamic> toMap() {
    return {
      'circleName': circleName,
      'avatarURL': avatarURL,
      'clockinCount': clockinCount
    };
  }
}
