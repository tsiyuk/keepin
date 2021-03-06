import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Comment.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:keepin/src/models/UserProfile.dart';

class PostProvider with ChangeNotifier {
  late String _postId;
  late String _posterId;
  late String _posterName;
  String? _posterAvatarLink;
  late String _circleName;
  late String _text;
  late String _title;
  List<String> _imageLinks = [];
  List<String> _tags = [];
  num _numOfLikes = 0;
  static User currentUser = FirebaseAuth.instance.currentUser!;

  static FirestoreService _firestoreService = FirestoreService();

  // Getters
  String get postId => _postId;
  String get posterId => _posterId;
  String get posterName => _posterName;
  String? get posterAvatarLink => _posterAvatarLink;
  String get circleName => _circleName;
  String get text => _text;
  String get title => _title;
  List<String> get imageLinks => _imageLinks;
  List<String> get tags => _tags;
  num get numOfLikes => _numOfLikes;
  Stream<List<Post>> get posts => _firestoreService.getPosts();
  Future<List<UserProfile>> get likedList =>
      _firestoreService.getLikedList(postId);

  static Stream<List<Comment>> getComments(String postId) {
    return FirestoreService.getComments(postId);
  }

  // Setters
  set changeAvatarURL(String avatarURL) {
    _posterAvatarLink = avatarURL;
    notifyListeners();
  }

  static Future<Post> readPost(String postId) async {
    return await FirestoreService.getPost(postId);
  }

  static Stream<List<Post>> readPostsFromCircle(String circleName) {
    return FirestoreService.getPostsFromCircle(circleName);
  }

  static Future<List<Comment>> readAllCommentsFromUser(String userId) {
    return FirestoreService.getAllComments(userId);
  }

  static Future<List<Map<String, dynamic>>> readAllLikesFromUser(
      String userId) {
    return FirestoreService.getAllLikes(userId);
  }

  static Stream<List<Post>> readPostsFromUser(String userId) {
    return FirestoreService.getPostsFromUser(userId);
  }

  static Future<List<Post>> readFollowPosts(String userId) {
    return FirestoreService.getPostsFromCirclesJoined(userId);
  }

  /// Initialize the provider
  void loadAll(Post post) {
    _postId = post.postId!;
    _posterId = post.posterId;
    _posterAvatarLink = post.posterAvatarLink;
    _circleName = post.circleName;
    _text = post.text;
    _imageLinks = post.imageLinks;
    _numOfLikes = post.numOfLikes;
    _tags = post.tags;
  }

  /// Must call it before create the post and upload the images
  void initPostInfo(User user, String circleName, List<String> tags) {
    _posterId = user.uid;
    _posterName = user.displayName!;
    _posterAvatarLink = user.photoURL;
    _circleName = circleName;
    _imageLinks = [];
    _tags = tags;
    notifyListeners();
  }

  void changeText(String text) {
    _text = text;
    notifyListeners();
  }

  void changeTitle(String title) {
    _title = title;
    notifyListeners();
  }

  void createPost() async {
    try {
      await _firestoreService.addPost(Post(
        posterId: posterId,
        posterName: posterName,
        posterAvatarLink: posterAvatarLink,
        circleName: circleName,
        text: text,
        title: title,
        imageLinks: imageLinks,
        numOfLikes: numOfLikes,
        timestamp: DateTime.now(),
        tags: tags,
      ));
    } on Exception catch (e) {
      print(e);
    }
  }

  /// Set an existing post in the firestore
  static void setPost(Post post) async {
    await FirestoreService.setPost(post);
  }

  /// Add a like to the post
  /// Use it when the post provider has been initialized
  void like() async {
    ++_numOfLikes;
    notifyListeners();
    var futures = <Future>[];
    futures.add(_firestoreService.updateLikes(
        postId, _numOfLikes, currentUser.uid, currentUser.displayName!));
    futures.add(_firestoreService.addLikeList(
        postId, currentUser.uid, currentUser.displayName!));
    await Future.wait(futures);
  }

  /// Add a like to the post
  /// Use it when the post provider has not been initialized
  void likeViaPost(Post post) async {
    ++post.numOfLikes;
    var futures = <Future>[];
    futures.add(_firestoreService.updateLikes(post.postId!, post.numOfLikes,
        currentUser.uid, currentUser.displayName!));
    futures.add(_firestoreService.addLikeList(
        post.postId!, currentUser.uid, currentUser.displayName!));
    await Future.wait(futures);
  }

  /// Reduce a like to the post
  /// Use it when the post provider has been initialized
  void unlike() async {
    --_numOfLikes;
    notifyListeners();
    var futures = <Future>[];
    futures.add(_firestoreService.updateLikes(
        postId, numOfLikes, currentUser.uid, currentUser.displayName!));
    futures.add(_firestoreService.deleteLikeList(postId, currentUser.uid));
    await Future.wait(futures);
  }

  /// Add a like to the post
  /// Use it when the post provider has not been initialized
  void unlikeViaPost(Post post) async {
    --post.numOfLikes;
    var futures = <Future>[];
    futures.add(_firestoreService.updateLikes(post.postId!, post.numOfLikes,
        currentUser.uid, currentUser.displayName!));
    futures
        .add(_firestoreService.deleteLikeList(post.postId!, currentUser.uid));
    await Future.wait(futures);
  }

  static Future<bool> hasLiked(Post post) {
    return FirestoreService.hasLiked(post.postId!, currentUser.uid);
  }

  /// upload images
  Future<void> uploadAssets(List<File> files) async {
    for (File file in files) {
      String fileName = file.path;
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('postAssets')
          .child(posterId)
          .child(fileName);
      await firebaseStorageRef.putFile(file);
      String imageLink = await firebaseStorageRef.getDownloadURL();
      _imageLinks.add(imageLink);
    }
    notifyListeners();
  }

  static void addComments(
      String postId, String text, String? replyTo, String? replyToId) async {
    await _firestoreService.addComment(Comment(
      postId: postId,
      commenterName: currentUser.displayName!,
      commenterId: currentUser.uid,
      text: text,
      timestamp: DateTime.now(),
      replyTo: replyTo,
      replyToId: replyToId,
    ));
  }

  void addPostHistory(Post post) async {
    await _firestoreService.updatePostHistory(
        currentUser.uid, post.posterId, post.tags);
  }

  static void deletePost(String postId) async {
    await FirestoreService.removePost(postId);
  }
}

class FirestoreService {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<Post> getPost(String postId) {
    return _firestore.collection('posts').doc(postId).get().then((value) {
      if (value.data() != null) {
        return Post.fromJson(value.data()!);
      } else {
        throw FirebaseException(
            plugin: 'FirebaseFirestore', code: 'Post does not exist');
      }
    });
  }

  Stream<List<Post>> getPosts() {
    return _firestore.collection('posts').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList());
  }

  static Stream<List<Post>> getPostsFromCircle(String circleName) {
    return _firestore
        .collection('posts')
        .where('circleName', isEqualTo: circleName)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList());
  }

  static Stream<List<Post>> getPostsFromUser(String userId) {
    return _firestore
        .collection('posts')
        .where('posterId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList());
  }

  static Future<List<Post>> getPostsFromCirclesJoined(String userId) async {
    List<String> circleNames = await _firestore
        .collection('userProfiles')
        .doc(userId)
        .collection('circlesJoined')
        .get()
        .then((value) => value.docs
            .map((value) => CircleInfo.fromJson(value.data()).circleName)
            .toList());

    List<Post> result = [];
    for (String circleName in circleNames) {
      var r = await _firestore
          .collection('posts')
          .where('circleName', isEqualTo: circleName)
          .orderBy('timestamp', descending: true)
          .get()
          .then((snapshot) {
        List<Post> result = [];
        for (QueryDocumentSnapshot item in snapshot.docs) {
          result.add(Post.fromJson(item.data()));
        }
        return result;
      });
      result.addAll(r);
    }
    result.sort((x, y) => x.compareTo(y));
    return result;
  }

  /// Read comments from the post specified by the postId
  static Stream<List<Comment>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromJson(doc.data())).toList());
  }

  static Future<List<Comment>> getAllComments(String userId) async {
    List<Post> posts = await _firestore
        .collection('posts')
        .where('posterId', isEqualTo: userId)
        .get()
        .then((value) =>
            value.docs.map((doc) => Post.fromJson(doc.data())).toList());

    List<Comment> result = [];
    for (Post post in posts) {
      var r = await _firestore
          .collection('posts')
          .doc(post.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .get()
          .then((snapshot) {
        List<Comment> result = [];
        for (QueryDocumentSnapshot item in snapshot.docs) {
          Comment comment = Comment.fromJson(item.data());
          comment.post = post;
          result.add(comment);
        }
        return result;
      });
      result.addAll(r);
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> getAllLikes(String userId) async {
    List<Post> posts = await _firestore
        .collection('posts')
        .where('posterId', isEqualTo: userId)
        .get()
        .then((value) =>
            value.docs.map((doc) => Post.fromJson(doc.data())).toList());

    List<Map<String, dynamic>> result = [];
    for (Post post in posts) {
      var r = await _firestore
          .collection('posts')
          .doc(post.postId)
          .collection('likes')
          .orderBy('timestamp', descending: true)
          .get()
          .then((snapshot) {
        List<Map<String, dynamic>> result = [];
        for (QueryDocumentSnapshot item in snapshot.docs) {
          Map<String, dynamic> likeData = item.data();
          likeData["post"] = post;
          result.add(likeData);
        }
        return result;
      });
      result.addAll(r);
    }
    return result;
  }

  Future<void> addPost(Post post) {
    var docRef = _firestore.collection('posts').doc();
    post.postId = docRef.id;
    return docRef.set(post.toMap());
  }

  static Future<void> setPost(Post post) {
    var setOption = SetOptions(merge: true);
    return _firestore
        .collection('posts')
        .doc(post.postId)
        .set(post.toMap(), setOption);
  }

  Future<void> updateLikes(
      String postId, num newNum, String userId, String userName) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .update({'numOfLikes': newNum});
  }

  Future<void> addLikeList(String postId, String userId, String userName) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .set({
      'userId': userId,
      'userName': userName,
      'postId': postId,
      'timestamp': DateTime.now(),
    });
  }

  Future<void> deleteLikeList(String postId, String userId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .delete();
  }

  Future<List<UserProfile>> getLikedList(String postId) async {
    List<String> userIds = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
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

  static Future<bool> hasLiked(String postId, String userId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId)
        .get()
        .then((value) => value.exists);
  }

  Future<void> updateImageLinks(String postId, List<String> imageLinks) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .update({'imageLinks': imageLinks});
  }

  Future<void> addComment(Comment comment) {
    return _firestore
        .collection('posts')
        .doc(comment.postId)
        .collection('comments')
        .add(comment.toMap());
  }

  Future<void> updatePostHistory(
      String userId, String postId, List<String> tags) {
    return _firestore
        .collection('userProfiles')
        .doc(userId)
        .collection('postHistory')
        .add({
      'postId': postId,
      'tags': tags,
      'timestamp': DateTime.now().toUtc(),
    });
  }

  static Future<void> removePost(String postId) async {
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection("comments")
        .doc()
        .delete();
    await _firestore
        .collection('posts')
        .doc(postId)
        .collection("likes")
        .doc()
        .delete();
    return _firestore.collection('posts').doc(postId).delete();
  }
}
