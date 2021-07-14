import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/models/ChatRoom.dart';
import 'package:keepin/src/models/Message.dart';
import 'package:keepin/src/services/UserState.dart';

/// Only support two people in one chat room
class ChatRoomProvider extends ChangeNotifier {
  List<String> _userIds = [];
  String _chatRoomId = '';
  List<bool> _unread = [];
  Message? _latestMessage;
  User currentUser = UserState.user!;

  // Getters
  List<String> get userIds => _userIds;
  Message? get latestMessage => _latestMessage;
  String get chatRoomId => _chatRoomId;
  List<bool> get unread => _unread;

  /// Return a stream of all the chat room the user belonged to
  Stream<List<ChatRoom>> get chatRooms =>
      FirestoreService.getChatRoomsByUser(currentUser.uid);
  Stream<List<Message>> get messages =>
      FirestoreService.getMessages(chatRoomId);

  /// Return a chat room where two given users are in
  Future<List<ChatRoom>> get specifiedChatRoom =>
      FirestoreService.getChatRoom(_userIds);

  /// Check if the given user is in the chat
  bool isInChat(String userId) {
    return userIds.contains(userId);
  }

  /// Check if the chat room has been read by the current user
  bool isUnRead(ChatRoom chatRoom) {
    List<String> ids = chatRoom.userIds;
    int index = ids.indexOf(currentUser.uid);
    return chatRoom.unread[index];
  }

  /// Get the userId of the other user in the chat room
  String getOtherUserId(ChatRoom chatRoom) {
    if (currentUser.uid == chatRoom.userIds[0]) {
      return chatRoom.userIds[1];
    } else {
      return chatRoom.userIds[0];
    }
  }

  String getReceiverId() {
    if (currentUser.uid == userIds[0]) {
      return userIds[1];
    } else {
      return userIds[0];
    }
  }

  // Setters
  void setNewUser(String userId) {
    _userIds.insert(0, currentUser.uid);
    _userIds.insert(1, userId);
    _userIds.sort();
    notifyListeners();
  }

  void loadAll(ChatRoom chatRoom) {
    _userIds = chatRoom.userIds;
    _chatRoomId = chatRoom.uid;
    _latestMessage = chatRoom.latestMessage;
    _unread = chatRoom.unread;
    notifyListeners();
  }

  void clear() {
    _userIds = [];
    _chatRoomId = '';
    _unread = [];
  }

  Future<ChatRoom> createChatRoom() async {
    String uid = FirestoreService.firestore.doc().id;
    ChatRoom chatRoom =
        ChatRoom(uid: uid, userIds: userIds, unread: [false, false]);
    await FirestoreService.addChatRoom(chatRoom);
    notifyListeners();
    return chatRoom;
  }

  Future<bool> isNotExist() {
    return FirestoreService.isNotExist(userIds);
  }

  void createMessage(String text, [String? inviteCircleName]) async {
    var message = Message(
        text: text,
        userId: currentUser.uid,
        receiverId: getReceiverId(),
        timestamp: DateTime.now(),
        inviteCircleName: inviteCircleName);
    _latestMessage = message;
    int index = userIds.indexOf(currentUser.uid);
    _unread[index] = false;
    _unread[1 - index] = true;
    notifyListeners();
    return FirestoreService.addMessage(chatRoomId, message, _unread);
  }

  /// Read the unread message,
  /// use it after check if the current user has read the message or not
  void readMessage() async {
    int index = userIds.indexOf(currentUser.uid);
    _unread[index] = false;
    FirestoreService.updateRead(chatRoomId, _unread);
  }
}

class FirestoreService {
  static CollectionReference firestore =
      FirebaseFirestore.instance.collection('chatrooms');

  static Future<void> addChatRoom(ChatRoom chatRoom) {
    return firestore
        .doc(chatRoom.uid)
        .set(chatRoom.toMap(), SetOptions(merge: true));
  }

  static Future<void> addMessage(
      String chatRoomId, Message message, List<bool> unread) {
    var futures = <Future>[];
    // add a new message
    futures.add(
        firestore.doc(chatRoomId).collection('messages').add(message.toMap()));
    // update the latest message and the unread array
    futures.add(firestore
        .doc(chatRoomId)
        .update({'latestMessage': message.toMap(), 'unread': unread}));
    return Future.wait(futures);
  }

  static Future<void> updateRead(String chatRoomId, List<bool> unread) {
    return firestore.doc(chatRoomId).update({'unread': unread});
  }

  static Stream<List<ChatRoom>> getChatRoomsByUser(String userId) {
    return firestore
        .where('userIds', arrayContains: userId)
        .orderBy('latestMessage.timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatRoom.fromJson(doc.data())).toList());
  }

  static Stream<List<Message>> getMessages(String chatRoomId) {
    return firestore
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList());
  }

  static Future<bool> isNotExist(List<String> ids) {
    return firestore.where('userIds', isEqualTo: ids).snapshots().isEmpty;
  }

  static Future<List<ChatRoom>> getChatRoom(List<String> ids) {
    return firestore.where('userIds', isEqualTo: ids).get().then(
        (value) => value.docs.map((e) => ChatRoom.fromJson(e.data())).toList());
  }

  static Future<void> deleteChatRoom(String chatRoomId) {
    return firestore.doc(chatRoomId).delete();
  }
}
