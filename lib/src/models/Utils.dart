import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class Utils {
  static DateTime toDateTime(Timestamp value) {
    return value.toDate();
  }

  static Future<File?> compress(File? file) async {
    if (file != null) {
      int index = file.path.lastIndexOf('/') + 1;
      String temp = file.path.substring(0, index);
      File? image;
      if (file.path.endsWith('.jpeg')) {
        var target =
            temp + DateTime.now().millisecondsSinceEpoch.toString() + '.jpeg';
        image = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path, target);
        return image;
      }
      if (file.path.endsWith('.jpg')) {
        var target =
            temp + DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
        image = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path, target);
        return image;
      }
      if (file.path.endsWith('.png')) {
        var target =
            temp + DateTime.now().millisecondsSinceEpoch.toString() + '.png';
        image = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path, target,
            format: CompressFormat.png);
        return image;
      }
      if (file.path.endsWith('.webp')) {
        var target =
            temp + DateTime.now().millisecondsSinceEpoch.toString() + '.webp';
        image = await FlutterImageCompress.compressAndGetFile(
            file.absolute.path, target,
            format: CompressFormat.webp);
        return image;
      }
      throw FirebaseException(
          plugin: 'Image Compress',
          code:
              'The format of the image is not supported, we support jpg/jpeg/png/webp');
    } else {
      throw FirebaseException(
          plugin: 'Image Compress', code: 'Upload image fail');
    }
  }
}
