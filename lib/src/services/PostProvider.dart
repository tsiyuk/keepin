import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
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

  // Initialize the provider
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

  void createPost() async {
    try {
      await _firestoreService.addPost(Post(
        posterId: posterId,
        posterName: posterName,
        posterAvatarLink: posterAvatarLink,
        circleName: circleName,
        text: text,
        imageLinks: imageLinks,
        numOfLikes: numOfLikes,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ));
    } on Exception catch (e) {
      print(e);
    }
  }

  void updateLikes() async {
    ++_numOfLikes;
    notifyListeners();
    _firestoreService.updateLikes(postId, numOfLikes);
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
      String replyToId) {
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
