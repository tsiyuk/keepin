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
  static final firestoreService = FirestoreService();
  static User user = FirebaseAuth.instance.currentUser!;
  static String _userId = FirebaseAuth.instance.currentUser!.uid;
  String _userName = FirebaseAuth.instance.currentUser!.displayName!;

  // Getters
  static String get userId => _userId;
  String get userName => _userName;
  static Stream<List<UserProfile>> get userProfiles =>
      firestoreService.getUserProfiles();
  static Stream<List<CircleInfo>> get circlesJoined =>
      firestoreService.getCirclesJoined(userId);
  static Future<List<Circle>> get circleHistory =>
      firestoreService.getCircleHistory(userId);
  static Future<List<Post?>> get postHistory =>
      firestoreService.getPostHistory(userId);

  /// get the userProfile instance specified by the userId
  static Stream<UserProfile> readUserProfile(String userId) {
    return firestoreService.getUserProfileStream(userId);
  }

  static Future<UserProfile> readUserProfileOnce(String userId) {
    return firestoreService.getUserProfileFuture(userId);
  }

  static Stream<List<Circle>> getRecommandCircles(List<String> tags) =>
      firestoreService.getRecommandCircle(tags);
  static Stream<List<Post>> getRecommandPost(List<String> tags) =>
      firestoreService.getRecommandPost(tags);

  static Stream<List<CircleInfo>> readCircleJoined(String id) =>
      firestoreService.getCirclesJoined(id);

  // save all the changes
  static Future<void> saveChanges(String userName, List<String> tags,
      String? avatarURL, String? bio) async {
    UserProfile userProfile =
        UserProfile(userId, userName, tags, avatarURL: avatarURL, bio: bio);
    user.updateDisplayName(userName);
    user.updatePhotoURL(avatarURL);
    await firestoreService.setUserProfile(userProfile);
  }

  static Future<void> createProfile(
      String userId, String userName, String? avatarURL) {
    return firestoreService.setUserProfile(
        UserProfile(userId, userName, [], avatarURL: avatarURL));
  }

  static Future<bool> isProfileExist() {
    return firestoreService.isExist(userId);
  }

  // upload avatar from the user's local gallery
  // maybe need to restrict the size of the uploaded image
  static Future<String> uploadPic(BuildContext context) async {
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
        await firebaseStorageRef.putFile(image);
        return await firebaseStorageRef.getDownloadURL();
      } else {
        throw FirebaseException(
            plugin: 'Firebase upload', code: 'Upload failed');
      }
    } else {
      throw FirebaseException(plugin: 'Firebase upload', code: 'Upload failed');
    }
  }

  static void updateAvatarURL(String url) async {
    await firestoreService.updateAvatarLink(userId, url);
  }

  /// Check if the posterName and posterAvatar have been updated
  /// If so, update it in the post
  static void updatePosterInfo(Post post) async {
    UserProfile userProfile = await readUserProfileOnce(post.posterId);
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

  static void updateToken(String token) async {
    await firestoreService.updateNotificationToken(userId, token);
  }

  static void changeTags(List<String> tags) async {
    await firestoreService.updateTags(userId, tags);
  }
}

class FirestoreService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Get user profiles
  Stream<List<UserProfile>> getUserProfiles() {
    return _firestore.collection('userProfiles').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => UserProfile.fromJson(doc.data())).toList());
  }

  Stream<UserProfile> getUserProfile(String userId) {
    return _firestore
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
    }).asStream();
  }

  Future<UserProfile> getUserProfileFuture(String userId) {
    return _firestore
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

  Stream<UserProfile> getUserProfileStream(String userId) {
    return _firestore
        .collection('userProfiles')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((event) => UserProfile.fromJson(event.docs[0].data()));
  }

  Future<bool> isExist(String userId) {
    return _firestore
        .collection('userProfiles')
        .doc(userId)
        .get()
        .then((value) => value.data() != null);
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

  Future<void> updateAvatarLink(String userId, String avatarURL) {
    return _firestore
        .collection('userProfiles')
        .doc(userId)
        .update({'avatarURL': avatarURL});
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
        //.orderBy('timestamp', descending: true)
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
