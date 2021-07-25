import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:keepin/src/models/ChatRoom.dart';
import 'package:keepin/src/models/Message.dart';
import 'package:keepin/src/services/UserState.dart';

/// Only support two people in one chat room
class ChatRoomAPI {
  static User currentUser = UserState.user!;

  /// Return a stream of all the chat room the user belonged to
  static Stream<List<ChatRoom>> getChatRooms() =>
      FirestoreService.getChatRoomsByUser(currentUser.uid);
  static Stream<List<Message>> getMessages(String chatRoomId) =>
      FirestoreService.getMessages(chatRoomId);

  static Future<ChatRoom?> getSpecifiedChatRoom(List<String> uids) {
    return FirestoreService.getChatRoom(uids);
  }

  /// Check if the chat room has been read by the current user
  static bool isUnRead(ChatRoom chatRoom) {
    List<String> ids = chatRoom.userIds;
    int index = ids.indexOf(currentUser.uid);
    return chatRoom.unread[index];
  }

  /// Get the userId of the other user in the chat room
  static String getOtherUserId(ChatRoom chatRoom) {
    if (currentUser.uid == chatRoom.userIds[0]) {
      return chatRoom.userIds[1];
    } else {
      return chatRoom.userIds[0];
    }
  }

  static String getReceiverId(ChatRoom chatRoom) {
    if (currentUser.uid == chatRoom.userIds[0]) {
      return chatRoom.userIds[1];
    } else {
      return chatRoom.userIds[0];
    }
  }


  static Future<ChatRoom> getOrCreateChatRoom(
      String userId1, String userId2) async {
    List<String> userIds = [userId1, userId2];
    userIds.sort();
    ChatRoom? result = await getSpecifiedChatRoom(userIds);
    if (result == null) {
      String uid = FirestoreService.firestore.doc().id;
      ChatRoom chatRoom =
          ChatRoom(uid: uid, userIds: userIds, unread: [false, false]);
      await FirestoreService.addChatRoom(chatRoom);
      return chatRoom;
    } else {
      return result;
    }
  }

  static void createMessage(ChatRoom chatRoom, String text,
      {String? inviteCircleName, String? postId}) async {
    var message = Message(
        text: text,
        userId: currentUser.uid,
        receiverId: getReceiverId(chatRoom),
        timestamp: DateTime.now(),
        inviteCircleName: inviteCircleName,
        postId: postId);
    chatRoom.latestMessage = message;
    int index = chatRoom.userIds.indexOf(currentUser.uid);
    chatRoom.unread[index] = false;
    chatRoom.unread[1 - index] = true;
    // notifyListeners();
    return FirestoreService.addMessage(chatRoom.uid, message, chatRoom.unread);
  }

  /// Read the unread message,
  /// use it after check if the current user has read the message or not
  static void readMessage(ChatRoom chatRoom) async {
    int index = chatRoom.userIds.indexOf(currentUser.uid);
    chatRoom.unread[index] = false;
    FirestoreService.updateRead(chatRoom.uid, chatRoom.unread);
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

  static Future<ChatRoom?> getChatRoom(List<String> ids) {
    return firestore.where('userIds', isEqualTo: ids).get().then((value) =>
        value.docs.isNotEmpty ? ChatRoom.fromJson(value.docs[0].data()) : null);
  }

  static Future<void> deleteChatRoom(String chatRoomId) {
    return firestore.doc(chatRoomId).delete();
  }
}
