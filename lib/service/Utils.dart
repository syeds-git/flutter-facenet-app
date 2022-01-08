import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class Utils {
  static Future<File> getImageFileFromAssets(String path, String tempName) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/${tempName}');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  static String getFileNameFromPath(String path) {
    return path.substring(path.lastIndexOf('/') + 1);
  }

  static Future<void> deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  static Future<void> deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if(appDir.existsSync()){
      appDir.deleteSync(recursive: true);
    }
  }
}