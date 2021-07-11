import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/models/UserProfile.dart';

class SearchService {
  static FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  static Stream<List<Circle>> searchCircle(String inputName) {
    return _firebaseFirestore
        .collection('circles')
        .where('circleName', isGreaterThanOrEqualTo: inputName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Circle.fromJson(doc.data())).toList());
  }

  static Stream<List<UserProfile>> searchUserProfile(String inputName) {
    return _firebaseFirestore
        .collection('userProfiles')
        .where('userName', isGreaterThanOrEqualTo: inputName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserProfile.fromJson(doc.data()))
            .toList());
  }

  static Stream<List<Post>> searchPost(String inputName) {
    return _firebaseFirestore
        .collection('posts')
        .where('text', isGreaterThanOrEqualTo: inputName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList());
  }
}
