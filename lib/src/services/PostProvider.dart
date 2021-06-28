import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/models/Circle.dart';
import 'package:keepin/src/models/Comment.dart';
import 'package:keepin/src/models/Post.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class PostProvider with ChangeNotifier {
  late String _postId;
  late String _posterId;
  late String _posterName;
  String? _posterAvatarLink;
  late String _circleName;
  late String _text;
  late String _title;
  List<String> _imageLinks = [];
  num _numOfLikes = 0;

  FirestoreService _firestoreService = FirestoreService();

  // Getters
  String get postId => _postId;
  String get posterId => _posterId;
  String get posterName => _posterName;
  String? get posterAvatarLink => _posterAvatarLink;
  String get circleName => _circleName;
  String get text => _text;
  String get title => _title;
  List<String> get imageLinks => _imageLinks;
  num get numOfLikes => _numOfLikes;
  Stream<List<Post>> get posts => _firestoreService.getPosts();

  Stream<List<Comment>> getComments(String postId) {
    return _firestoreService.getComments(postId);
  }

  // Setters
  set changeAvatarURL(String avatarURL) {
    _posterAvatarLink = avatarURL;
    notifyListeners();
  }

  Stream<List<Post>> readPostsFromCircle(String circleName) {
    return _firestoreService.getPostsFromCircle(circleName);
  }

  Stream<List<Post>> readPostsFromUser(String userId) {
    return _firestoreService.getPostsFromUser(userId);
  }

  Future<List<Post>> readFollowPosts(String userId) {
    return _firestoreService.getPostsFromCirclesJoined(userId);
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
  }

  /// Must call it before create the post and upload the images
  void initPostInfo(User user, String circleName) {
    _posterId = user.uid;
    _posterName = user.displayName!;
    _posterAvatarLink = user.photoURL;
    _circleName = circleName;
    _imageLinks = [];
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
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    } on Exception catch (e) {
      print(e);
    }
  }

  /// Add a like to the post
  /// Use it when the post provider has been initialized
  void like() async {
    ++_numOfLikes;
    notifyListeners();
    await _firestoreService.updateLikes(postId, numOfLikes);
  }

  /// Add a like to the post
  /// Use it when the post provider has not been initialized
  void likeViaPost(Post post) async {
    ++post.numOfLikes;
    await _firestoreService.updateLikes(post.postId!, post.numOfLikes);
  }

  /// Reduce a like to the post
  /// Use it when the post provider has been initialized
  void unlike() async {
    --_numOfLikes;
    notifyListeners();
    await _firestoreService.updateLikes(postId, numOfLikes);
  }

  /// Add a like to the post
  /// Use it when the post provider has not been initialized
  void unlikeViaPost(Post post) async {
    --post.numOfLikes;
    await _firestoreService.updateLikes(post.postId!, post.numOfLikes);
  }

  /// upload images
  Future uploadAssets(BuildContext context) async {
    final List<AssetEntity>? assets = await AssetPicker.pickAssets(context);
    if (assets != null) {
      for (AssetEntity asset in assets) {
        if (await asset.exists) {
          File? file = await asset.file;
          if (file != null) {
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
        }
      }
    }
    notifyListeners();
  }

  void addComments(String postId, User commenter, String text, String? replyTo,
      String? replyToId) {
    _firestoreService.addComment(Comment(
      postId: postId,
      commenterName: commenter.displayName!,
      commenterId: commenter.uid,
      text: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      replyTo: replyTo,
      replyToId: replyToId,
    ));
  }
}

class FirestoreService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Post>> getPosts() {
    return _firestore.collection('posts').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList());
  }

  Stream<List<Post>> getPostsFromCircle(String circleName) {
    return _firestore
        .collection('posts')
        .where('circleName', isEqualTo: circleName)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList());
  }

  Stream<List<Post>> getPostsFromUser(String userId) {
    return _firestore
        .collection('posts')
        .where('posterId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList());
  }

  // TODO: maybe return a stream
  Future<List<Post>> getPostsFromCirclesJoined(String userId) async {
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
    // result.sort((x, y) => x.compareTo(y));
    return result;
  }

  /// Read comments from the post specified by the postId
  Stream<List<Comment>> getComments(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Comment.fromJson(doc.data())).toList());
  }

  Future<void> addPost(Post post) {
    var docRef = _firestore.collection('posts').doc();
    post.postId = docRef.id;
    return docRef.set(post.toMap());
  }

  Future<void> updateLikes(String postId, num newNum) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .update({'numOfLikes': newNum});
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

  Future<void> removePost(String postId) {
    return _firestore.collection('posts').doc(postId).delete();
  }
}
