import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/UserProfile.dart';
import 'package:keepin/src/models/Utils.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class CircleProvider with ChangeNotifier {
  final num CLOCK_IN_EXP = 10;
  final num POST_EXP = 20;
  late String _circleName;
  late String _circleAvatarURL;
  User _user = FirebaseAuth.instance.currentUser!;
  List<String> _tags = [];
  late String _adminUserId;
  late num _numOfMembers;
  late bool _isPublic;

  /// clockinCount is for the specifiled user
  num _clockinCount = 0;
  DateTime _lateClockinTime = DateTime(1970);
  num _exp = 0;
  String? _description;
  List<String>? _descriptionImageURLs = [];
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
  DateTime get lastClockinTime => _lateClockinTime;
  num get exp => _exp;
  String? get description => _description;
  List<String>? get descriptionImageURLs => _descriptionImageURLs;

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

  /// Get the circle info from the current user
  /// Call this function after using isMember to check whether the current user has joined the circle.
  Future<CircleInfo> readCircleInfoFromUser() async {
    if (await isMember(_user.uid)) {
      return await _firestoreService.getCircleInfoFromUser(
          user.uid, circleName);
    } else {
      throw Exception('The user has not joined the circle');
    }
  }

  /// Get the user ranking of the circle
  Stream<List<RankingInfo>> readUserRank() {
    return _firestoreService.getRankingInfo(circleName);
  }

  static Future<List<UserProfile>> readUserInfos(String name) {
    return FirestoreService.getUsers(name);
  }

  // Checking
  bool isAdmin(String userId) {
    return userId == _adminUserId;
  }

  Future<bool> isMember(String userId) async {
    return await _firestoreService.isMemberExist(circleName, user.uid);
  }

  // Setters
  void loadAll(Circle circle, CircleInfo? circleInfo) {
    _circleName = circle.circleName;
    _circleAvatarURL = circle.avatarURL;
    _adminUserId = circle.adminUserId;
    _tags = circle.tags;
    _numOfMembers = circle.numOfMembers;
    _isPublic = circle.isPublic;
    _description = circle.description;
    _descriptionImageURLs = circle.descriptionImageURLs;
    if (circleInfo != null) {
      _clockinCount = circleInfo.clockinCount;
      _lateClockinTime = circleInfo.lastClockinTime;
      _exp = circleInfo.exp;
    }
  }

  /// call upload avatar before create a circle
  Future<File> uploadAvatar(BuildContext context) async {
    final List<AssetEntity>? assets =
        await AssetPicker.pickAssets(context, maxAssets: 1);
    if (assets != null) {
      File? image = await Utils.compress(await assets[0].file);
      _avatar = image;
      notifyListeners();
      return Future.value(_avatar!);
    } else {
      throw Exception('image not uploaded');
    }
  }

  Future<void> createCircle(
      String circleName, List<String> tags, bool isPublic) async {
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

  Future<void> clockin() async {
    if (await isMember(user.uid)) {
      DateTime last = lastClockinTime;
      DateTime now = DateTime.now();
      if (now.day != last.day ||
          now.month != last.month ||
          now.year != last.year) {
        ++_clockinCount;
        notifyListeners();
        var futures = <Future>[];
        futures.add(addExp(CLOCK_IN_EXP));
        futures.add(_firestoreService.updateClockin(
            circleName, user.uid, clockinCount, now));
        await Future.wait(futures);
      } else {
        throw FirebaseException(
            plugin: 'Firebase',
            code: 'Can not clock in twice in the same day!');
      }
    } else {
      throw FirebaseException(
          plugin: 'Firebase', code: 'Please join the circle first');
    }
  }

  Future<void> addExp(num exp) {
    _exp += exp;
    notifyListeners();
    return _firestoreService.updateExp(circleName, user.uid, _exp);
  }

  /// Upload Descirption Images
  Future uploadDescirptionImages(BuildContext context) async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(context);
    if (assets != null) {
      for (AssetEntity asset in assets) {
        if (await asset.exists) {
          File? file = await asset.file;
          if (file != null) {
            String fileName = file.path;
            Reference firebaseStorageRef = FirebaseStorage.instance
                .ref()
                .child('circleAssets')
                .child(circleName)
                .child(fileName);
            await firebaseStorageRef.putFile(file);
            String imageLink = await firebaseStorageRef.getDownloadURL();
            _descriptionImageURLs!.add(imageLink);
          }
        }
      }
    }
    notifyListeners();
  }

  void setDescritpion(String text) async {
    _description = text;
    await _firestoreService.updateDescription(
        circleName, _description, _descriptionImageURLs);
    notifyListeners();
  }

  void addCircleHistory(Circle circle) async {
    await _firestoreService.updateCircleHistory(
        user.uid, circle.circleName, circle.tags);
  }

  void setTags(List<String> tags) async {
    await _firestoreService.updateTags(circleName, tags);
  }

  /// quit the circle
  Future<void> quitCircle() async {
    if (isAdmin(user.uid)) {
      throw FirebaseException(
          plugin: 'firebasefirestore', code: 'Admin can not quit the circle');
    } else {
      _exp = 0;
      _clockinCount = 0;
      notifyListeners();
      await _firestoreService.removeUser(circleName, user.uid);
    }
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

  Future<CircleInfo> getCircleInfoFromUser(String userId, String circleName) {
    return _firebaseFirestore
        .collection('userProfiles')
        .doc(userId)
        .collection('circlesJoined')
        .doc(circleName)
        .get()
        .then((value) {
      if (value.data() != null) {
        return CircleInfo.fromJson(value.data()!);
      } else {
        throw FirebaseException(
            plugin: 'FirebaseFirestore',
            code: 'The circle have not been created');
      }
    });
  }

  static Future<List<UserProfile>> getUsers(String circleName) async {
    List<String> userIds = await FirebaseFirestore.instance
        .collection('circles')
        .doc(circleName)
        .collection('userIds')
        .orderBy('exp', descending: true)
        .limit(10)
        .get()
        .then((value) => value.docs
            .map((value) => value.data()['userId'].toString())
            .toList());
    List<UserProfile> result = [];
    for (String userId in userIds) {
      var r = await FirebaseFirestore.instance
          .collection('userProfiles')
          .doc(userId)
          .get()
          .then((value) => UserProfile.fromJson(value.data()!));
      result.add(r);
    }
    return result;
  }

  Stream<List<RankingInfo>> getRankingInfo(String circleName) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .collection('userIds')
        .orderBy('exp', descending: true)
        .snapshots()
        .map((event) =>
            event.docs.map((doc) => RankingInfo.fromJson(doc.data())).toList());
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
        .set(CircleInfo(circleName, circleAvatar, 0, DateTime.utc(1970), 0)
            .toMap());
  }

  Future<void> updateClockin(
      String circleName, String userId, num count, DateTime newTime) {
    return _firebaseFirestore
        .collection('userProfiles')
        .doc(userId)
        .collection('circlesJoined')
        .doc(circleName)
        .update({'clockinCount': count, 'lastClockinTime': newTime});
  }

  /// Update the exp of the user
  Future<void> updateExp(String circleName, String userId, num exp) {
    var futures = <Future>[];
    futures.add(_firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .collection('userIds')
        .doc(userId)
        .update({'exp': exp}));
    futures.add(_firebaseFirestore
        .collection('userProfiles')
        .doc(userId)
        .collection('circlesJoined')
        .doc(circleName)
        .update({'exp': exp}));
    return Future.wait(futures);
  }

  /// Add an admin
  /// should be call after creating a new circle
  Future<void> addAdmin(Circle circle) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circle.circleName)
        .collection('userIds')
        .doc(circle.adminUserId)
        .set({
      'userId': circle.adminUserId,
      'isAdmin': true,
      'exp': 0,
    });
  }

  /// Add a new user
  Future<void> addUser(String circleName, String userId) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .collection('userIds')
        .doc(userId)
        .set({
      'userId': userId,
      'isAdmin': false,
      'exp': 0,
    });
  }

  Future<void> updateNumOfMember(String circleName, num count) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .update({'numOfMembers': count});
  }

  /// Add or update description
  Future<void> updateDescription(
      String circleName, String? description, List<String>? urls) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .update({'description': description, 'descriptionImageURLs': urls});
  }

  Future<void> updateCircleHistory(
      String userId, String circleName, List<String> tags) {
    return _firebaseFirestore
        .collection('userProfiles')
        .doc(userId)
        .collection('circleHistory')
        .add({
      'circleName': circleName,
      'tags': tags,
      'timestamp': DateTime.now().toUtc(),
    });
  }

  Future<void> updateTags(String circleName, List<String> tags) {
    return _firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .update({'tags': tags});
  }

  // remove a user from the circle
  Future<void> removeUser(String circleName, String userId) {
    var futures = <Future>[];
    futures.add(_firebaseFirestore
        .collection('userProfiles')
        .doc(userId)
        .collection('circlesJoined')
        .doc(circleName)
        .delete());
    futures.add(_firebaseFirestore
        .collection('circles')
        .doc(circleName)
        .collection('userIds')
        .doc(userId)
        .delete());
    return Future.wait(futures);
  }

  // Take note that the userIds will not be removed because
  // firestore do not recommand delete collections
  Future<void> removeCircle(String circleName) {
    return _firebaseFirestore.collection('circles').doc(circleName).delete();
  }
}
