import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/UserProfile.dart';

/*
  This class provide the methods related to CURD of UserProfile
*/
class UserProfileProvider with ChangeNotifier {
  final firestoreService = FirestoreService();
  String? _avatarURL;
  User user = FirebaseAuth.instance.currentUser!;
  String _userId = FirebaseAuth.instance.currentUser!.uid;
  String _userName = FirebaseAuth.instance.currentUser!.displayName!;

  // Getters
  String get userId => _userId;
  String get userName => _userName;
  String? get avatarURL => _avatarURL;
  Stream<List<UserProfile>> get userProfiles =>
      firestoreService.getUserProfiles();
  Stream<List<CircleInfo>> get circlesJoined =>
      firestoreService.getCirclesJoined(userId);

  // Setters
  void changeUserName(String userName) {
    _userName = userName;
    notifyListeners();
  }

  // load all the information from the userProfile instance
  void load(UserProfile userProfile) {
    _userId = userProfile.userId;
    _userName = userProfile.userName;
    _avatarURL = userProfile.avatarURL;
  }

  // save all the changes
  void saveChanges() {
    UserProfile userProfile =
        UserProfile(userId, userName, avatarURL: avatarURL);
    user.updateProfile(displayName: userName, photoURL: avatarURL);
    firestoreService.setUserProfile(userProfile);
  }

  // upload avatar from the user's local gallery
  // maybe need to restrict the size of the uploaded image
  Future uploadPic(BuildContext context) async {
    ImagePicker imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      String fileName = image.path;
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('userAvatars')
          .child(userId)
          .child(fileName);
      TaskSnapshot task = await firebaseStorageRef.putFile(image);
      _avatarURL = await firebaseStorageRef.getDownloadURL();
      notifyListeners();
    }
  }

  // get the userProfile instance specified by the userId
  Future<UserProfile> userProfile(String userId) async {
    return await firestoreService.getUserProfile(userId);
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
        return UserProfile(user.uid, user.displayName!,
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

  // Delete
  Future<void> removeUserProfile(String userId) {
    return _firestore.collection('userProfiles').doc(userId).delete();
  }
}
