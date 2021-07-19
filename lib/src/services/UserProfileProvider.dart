import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/models/Utils.dart';
import 'package:keepin/src/services/PostProvider.dart';

/*
  This class provide the methods related to CURD of UserProfile
*/
class UserProfileProvider with ChangeNotifier {
  final firestoreService = FirestoreService();
  String? _avatarURL;
  String? _bio;
  User user = FirebaseAuth.instance.currentUser!;
  String _userId = FirebaseAuth.instance.currentUser!.uid;
  String _userName = FirebaseAuth.instance.currentUser!.displayName!;
  List<String> _tags = [];

  // Getters
  String get userId => _userId;
  String get userName => _userName;
  String? get avatarURL => _avatarURL;
  String? get bio => _bio;
  List<String> get tags => _tags;
  Stream<List<UserProfile>> get userProfiles =>
      firestoreService.getUserProfiles();
  Stream<List<CircleInfo>> get circlesJoined =>
      firestoreService.getCirclesJoined(userId);
  Future<List<Circle>> get circleHistory =>
      firestoreService.getCircleHistory(userId);
  Future<List<Post?>> get postHistory =>
      firestoreService.getPostHistory(userId);

  /// get the userProfile instance specified by the userId
  Future<UserProfile> readUserProfile(String userId) async {
    return await firestoreService.getUserProfile(userId);
  }

  Stream<List<Circle>> get recommandCircles =>
      firestoreService.getRecommandCircle(tags);
  Stream<List<Post>> get recommandPost =>
      firestoreService.getRecommandPost(tags);

  // Setters
  void changeUserName(String userName) {
    _userName = userName;
    notifyListeners();
  }

  void changeBio(String newBio) {
    _bio = newBio;
    notifyListeners();
  }

  // load all the information from the userProfile instance
  void load(UserProfile userProfile) {
    _userId = userProfile.userId;
    _userName = userProfile.userName;
    _avatarURL = userProfile.avatarURL;
    _bio = userProfile.bio;
    _tags = userProfile.tags;
  }

  // save all the changes
  void saveChanges() {
    UserProfile userProfile =
        UserProfile(userId, userName, tags, avatarURL: avatarURL, bio: bio);
    user.updateDisplayName(userName);
    user.updatePhotoURL(avatarURL);
    firestoreService.setUserProfile(userProfile);
  }

  // upload avatar from the user's local gallery
  // maybe need to restrict the size of the uploaded image
  Future uploadPic(BuildContext context) async {
    ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      File? image = await Utils.compress(file);
      if (image != null) {
        String fileName = image.path;
        Reference firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('userAvatars')
            .child(userId)
            .child(fileName);
        TaskSnapshot task = await firebaseStorageRef.putFile(image);
        _avatarURL = await firebaseStorageRef.getDownloadURL();
        notifyListeners();
      } else {
        throw FirebaseException(
            plugin: 'Firebase upload', code: 'Upload failed');
      }
    }
  }

  /// Check if the posterName and posterAvatar have been updated
  /// If so, update it in the post
  void updatePosterInfo(Post post) async {
    UserProfile userProfile = await readUserProfile(post.posterId);
    bool dirty = false;
    if (userProfile.userName != post.posterName) {
      post.posterName = userProfile.userName;
      dirty = true;
    }
    if (userProfile.avatarURL != post.posterAvatarLink) {
      post.posterAvatarLink = userProfile.avatarURL;
      dirty = true;
    }
    if (dirty) {
      PostProvider.setPost(post);
    }
  }

  void updateToken(String token) async {
    await firestoreService.updateNotificationToken(userId, token);
  }

  void changeTags(List<String> tags) async {
    _tags = tags;
    await firestoreService.updateTags(userId, tags);
    notifyListeners();
  }
}

class FirestoreService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Get user profiles
  Stream<List<UserProfile>> getUserProfiles() {
    return _firestore.collection('userProfiles').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserProfile.fromJson(doc.data())).toList());
  }

  Future<UserProfile> getUserProfile(String userId) async {
    return await _firestore
        .collection('userProfiles')
        .doc(userId)
        .get()
        .then((value) {
      if (value.data() != null) {
        return UserProfile.fromJson(value.data()!);
      } else {
        User user = FirebaseAuth.instance.currentUser!;
        return UserProfile(user.uid, user.displayName!, [],
            avatarURL: user.photoURL);
      }
    });
  }

  Stream<List<CircleInfo>> getCirclesJoined(String userId) {
    return _firestore
        .collection('userProfiles')
        .doc(userId)
        .collection('circlesJoined')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CircleInfo.fromJson(doc.data()))
            .toList());
  }

  // Update or Insert
  Future<void> setUserProfile(UserProfile userProfile) {
    var options = SetOptions(merge: true);

    return _firestore
        .collection('userProfiles')
        .doc(userProfile.userId)
        .set(userProfile.toMap(), options);
  }

  Future<void> updateNotificationToken(String userId, String token) {
    return _firestore
        .collection('userProfiles')
        .doc(userId)
        .update({'notificationToken': token});
  }

  /// Circle history
  Future<List<Circle>> getCircleHistory(String userId) async {
    List<String> circleNames = await _firestore
        .collection('userProfiles')
        .doc(userId)
        .collection('circleHistory')
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) => value.docs
            .map((value) => value.data()['circleName'].toString())
            .toList());

    List<Circle> result = [];
    for (String circleName in circleNames) {
      var r = await _firestore
          .collection('circles')
          .where('circleName', isEqualTo: circleName)
          .get()
          .then((snapshot) {
        List<Circle> result = [];
        for (QueryDocumentSnapshot item in snapshot.docs) {
          result.add(Circle.fromJson(item.data()));
        }
        return result;
      });
      result.addAll(r);
    }
    return result;
  }

  /// Post History
  /// Return the history post, null means the post has been deleted
  Future<List<Post?>> getPostHistory(String userId) async {
    List<String> postIds = await _firestore
        .collection('userProfiles')
        .doc(userId)
        .collection('postHistory')
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) => value.docs
            .map((value) => value.data()['postId'].toString())
            .toList());

    List<Post?> result = [];
    for (String postId in postIds) {
      var r = await _firestore.collection('posts').doc(postId).get().then(
          (value) =>
              value.data() != null ? Post.fromJson(value.data()!) : null);
      result.add(r);
    }
    return result;
  }

  Stream<List<Circle>> getRecommandCircle(List<String> tags) {
    return _firestore
        .collection('circles')
        .where('tags', arrayContainsAny: tags)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Circle.fromJson(doc.data())).toList());
  }

  Stream<List<Post>> getRecommandPost(List<String> tags) {
    return _firestore
        .collection('posts')
        .where('tags', arrayContainsAny: tags)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList());
  }

  Future<void> updateTags(String userId, List<String> tags) {
    return _firestore
        .collection('userProfiles')
        .doc(userId)
        .update({'tags': tags});
  }

  // Delete
  Future<void> removeUserProfile(String userId) {
    return _firestore.collection('userProfiles').doc(userId).delete();
  }
}
