class UserProfile {
  final String userId;
  final String userName;
  String? avatarURL;

  UserProfile(this.userId, this.userName, {this.avatarURL});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(json['userId'], json['userName'],
        avatarURL: json['avatarURL']);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'avatarURL': avatarURL,
    };
  }
}
