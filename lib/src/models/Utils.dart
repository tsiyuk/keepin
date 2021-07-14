import 'package:cloud_firestore/cloud_firestore.dart';

class Utils {
  static DateTime toDateTime(Timestamp value) {
    return value.toDate();
  }
}
