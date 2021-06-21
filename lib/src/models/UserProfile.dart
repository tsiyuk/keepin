/*
  This class contains all the information about user profile:
    userId: the unique id
    userName: the display name
    avatarURL: the link to download the user's avatar from the firebase storage
*/

class UserProfile {
  final String userId;
  final String userName;
  String? avatarURL;
  //posts

  UserProfile(this.userId, this.userName, {this.avatarURL});

  // factory method to retrive data from firestore
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(json['userId'], json['userName'],
        avatarURL: json['avatarURL']);
  }

  // transform the UserProfile instance into the json form
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'avatarURL': avatarURL,
    };
  }
}
