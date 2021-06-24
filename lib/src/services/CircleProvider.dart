import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class CircleProvider with ChangeNotifier {
  late String _circleName;
  late String _circleAvatarURL;
  // assume we only allow
  User _user = FirebaseAuth.instance.currentUser!;
  List<String> _tags = [];
  late String _adminUserId;
  late num _numOfMembers;
  late bool _isPublic;

  /// clockinCount is for the specifiled user
  late num _clockinCount;
  File? _avatar;

  FirestoreService _firestoreService = FirestoreService();

  // Getters
  String get circleName => _circleName;
  String get circleAvatarURL => _circleAvatarURL;
  User get user => _user;
  List<String> get tags => _tags;
  num get numOfMembers => _numOfMembers;
  bool get isPublic => _isPublic;
  num get clockinCount => _clockinCount;

  Stream<List<Circle>> get allCircles => _firestoreService.getCircles();

  /// Query all the public circles
  Stream<List<Circle>> get publicCircles =>
      _firestoreService.getPublicCircles();

  /// Query circle inforamtion to demonstrate the circle feed
  Stream<List<CircleInfo?>> readCirclesFromUser(String userId) {
    return _firestoreService.getCircleInfosFromUser(userId);
  }

  /// Use circle name to query the circle
  Future<Circle> readCircleFromName(String name) async {
    if (await _firestoreService.isCircleExist(name)) {
      return _firestoreService.getCircleFromName(name);
    } else {
      throw Exception('The circle does not exist');
    }
  }

  // Checking
  bool isAdmin(String userId) {
    return userId == _adminUserId;
  }

  Future<bool> isMember(String userId) async {
    return await _firestoreService.isMemberExist(circleName, user.uid);
  }

  // Setters
  void loadAll(Circle circle, CircleInfo circleInfo) {
    _circleName = circle.circleName;
    _circleAvatarURL = circle.avatarURL;
    _adminUserId = circle.adminUserId;
    _tags = circle.tags;
    _numOfMembers = circle.numOfMembers;
    _isPublic = circle.isPublic;
    _clockinCount = circleInfo.clockinCount;
  }

  /// call upload avatar before create a circle
<<<<<<< HEAD
  /// Throw an exxception when no image is selected
  void uploadAvatar(BuildContext context) async {
=======
  Future<File> uploadAvatar(BuildContext context) async {
>>>>>>> refs/remotes/origin/cx/circle&post
    final List<AssetEntity>? assets =
        await AssetPicker.pickAssets(context, maxAssets: 1);
    if (assets != null) {
      _avatar = await assets[0].file;
      notifyListeners();
      return Future.value(_avatar!);
    } else {
      throw Exception('image not uploaded');
    }
  }

<<<<<<< HEAD
  /// create a new circle
  /// Throw an exception when the circle with [circleName] has already existed
  /// Throw an exception when the circle avatar has not been uploaded
  void createCircle(String circleName, List<String> tags, bool isPublic) async {
=======
  Future<void> createCircle(
      String circleName, List<String> tags, bool isPublic) async {
>>>>>>> refs/remotes/origin/cx/circle&post
    if (await _firestoreService.isCircleExist(circleName)) {
      throw Exception('The circle $circleName has already existed');
    }
    if (_avatar == null) {
      throw Exception('Circle avatar has not been uploaded');
    } else {
      _circleName = circleName;
      _tags = tags;
      _adminUserId = user.uid;
      _numOfMembers = 1;
      notifyListeners();

      // upload the avatar to the firebase
      String fileName = _avatar!.path;
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('circleAssets')
          .child(circleName)
          .child(fileName);
      await firebaseStorageRef.putFile(_avatar!);
      _circleAvatarURL = await firebaseStorageRef.getDownloadURL();
      notifyListeners();
      Circle circle = Circle(
          circleName: circleName,
          avatarURL: _circleAvatarURL,
          tags: _tags,
          adminUserId: _adminUserId,
          numOfMembers: _numOfMembers,
          isPublic: isPublic);
      var futures = <Future<void>>[];
      // create a new circle doc
      futures.add(_firestoreService.setCircle(circle));
      // add an admin user to the circle doc
      futures.add(_firestoreService.addAdmin(circle));
      // update the user profile
      futures.add(_firestoreService.updateUserProfile(
          _circleName, _circleAvatarURL, _adminUserId));
      await Future.wait(futures);
    }
  }

  /// Need to ask the user to upload a new avatar
  void updateAvatar() async {
    String fileName = _avatar!.path;
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('circleAssets')
        .child(circleName)
        .child(fileName);
    await firebaseStorageRef.putFile(_avatar!);
    _circleAvatarURL = await firebaseStorageRef.getDownloadURL();
    notifyListeners();
    await _firestoreService.updateAvatarURL(circleName, _circleAvatarURL);
  }

  /// Enable the current user to join the circle
  void joinCircle() async {
    ++_numOfMembers;
    notifyListeners();
    var futures = <Future<void>>[];
    // add the user to the circle doc
    futures.add(_firestoreService.addUser(circleName, user.uid));
    // update userProfile doc
    futures.add(_firestoreService.updateUserProfile(
        circleName, circleAvatarURL, user.uid));
    // update number of user in the circle doc
    futures.add(_firestoreService.updateNumOfMember(circleName, numOfMembers));
    await Future.wait(futures);
  }

  void clockin() async {
    ++_clockinCount;
    notifyListeners();
    await _firestoreService.updateClockinCount(
        circleName, user.uid, clockinCount);
  }
}

class FirestoreService {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  // Read
  Stream<List<Circle>> getCircles() {
    return _firebaseFirestore.collection('circles').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Circle.fromJson(doc.data())).toList());
  }

  Stream<List<Circle>> getPublicCircles() {
    return _firebaseFirestore
        .collection('circles')
        .where('isPublic', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Circle.fromJson(doc.data())).toList());
  }

  /// To display circle avatar and circle name at the circles feed
  Stream<List<CircleInfo?>> getCircleInfosFromUser(String userId) {
    return _firebaseFirestore
        .collection('userProfiles')
        .doc(userId)
        .collection('circlesJoined')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return CircleInfo.fromJson(doc.data());
            }).toList());
  }

  Future<Circle> getCircleFromName(String name) {
    return _firebaseFirestore
        .collection('circles')
        .doc(name)
        .get()
        .then((value) {
      if (value.data() != null) {
        return Circle.fromJson(value.data()!);
      } else {
        throw FirebaseException(
            plugin: 'FirebaseFirestore',
            code: 'The circle have not been created');
      }
    });
  }

  Future<bool> isCircleExist(String name) {
    return _firebaseFirestore
        .collection('circles')
        .doc(name)
        .get()
        .then((value) => value.exists);
  }

  Future<bool> isMemberExist(String circleName, String userId) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .collection('userIds')
        .doc(userId)
        .get()
        .then((value) => value.exists);
  }

  // Create and update
  Future<void> setCircle(Circle circle) {
    var setOption = SetOptions(merge: true);
    return _firebaseFirestore
        .collection('circles')
        .doc(circle.circleName)
        .set(circle.toMap(), setOption);
  }

  Future<void> updateAvatarURL(String circleName, String avatarURL) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .update({'avatarURL': avatarURL});
  }

  Future<void> updateUserProfile(
      String circleName, String circleAvatar, String userId) {
    return _firebaseFirestore
        .collection('userProfiles')
        .doc(userId)
        .collection('circlesJoined')
        .doc(circleName)
        .set(CircleInfo(circleName, circleAvatar, 0).toMap());
  }

  Future<void> updateClockinCount(String circleName, String userId, num count) {
    return _firebaseFirestore
        .collection('userProfiles')
        .doc(userId)
        .collection('circlesJoined')
        .doc(circleName)
        .update({'clockinCount': count});
  }

  // Add an admin
  // should be call after creating a new circle
  Future<void> addAdmin(Circle circle) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circle.circleName)
        .collection('userIds')
        .doc(circle.adminUserId)
        .set({
      'userId': circle.adminUserId,
      'isAdmin': true,
    });
  }

  // Add a new user
  Future<void> addUser(String circleName, String userId) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .collection('userIds')
        .doc(userId)
        .set({
      'userId': userId,
      'isAdmin': false,
    });
  }

  Future<void> updateNumOfMember(String circleName, num count) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .update({'numOfMembers': count});
  }

  // remove a user from the circle
  Future<void> removeUser(String circleName, String userId) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .collection('userIds')
        .doc(userId)
        .delete();
  }

  // Take note that the userIds will not be removed because
  // firestore do not recommand delete collections
  Future<void> removeCircle(String circleName) {
    return _firebaseFirestore.collection('circles').doc(circleName).delete();
  }
}
