import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:keepin/src/models/Tag.dart';

class TagProvider {
  static FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<List<Tag>> readTags() {
    return _db.collection('tags').get().then((value) {
      List<Tag> result = [];
      value.docs.forEach((element) {
        result.add(Tag.fromJson(element.data()));
      });
      print(result);
      return result;
    });
  }

  static Future<void> addTag(String name) {
    Tag tag = Tag(name, 0);
    return _db.collection('tags').doc(name).set(tag.toMap());
  }

  static Future<void> isExist(String name) {
    return _db.collection('tags').doc(name).get().then((value) => value.exists);
  }

  static Future<void> updateCount(String name, num n) {
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('users').doc(name);

    return FirebaseFirestore.instance
        .runTransaction((transaction) async {
          // Get the document
          DocumentSnapshot snapshot = await transaction.get(documentReference);

          if (!snapshot.exists) {
            throw Exception("Tag does not exist!");
          }

          int newFollowerCount = snapshot.data()!['count'] + n;
          transaction.update(documentReference, {'count': newFollowerCount});

          // Return the new count
          return newFollowerCount;
        })
        .then((value) => print("Follower count updated to $value"))
        .catchError(
            (error) => print("Failed to update user followers: $error"));
  }
}
