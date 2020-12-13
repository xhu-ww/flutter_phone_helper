import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FileChannel {
  final MethodChannel channel = MethodChannel('plugins.flutter.file_channel');

  Future<String> getResourcesADBPath() {
    if (Platform.isMacOS) {
      return channel.invokeMethod<String>('getResourcesADBPath');
    } else {
      return Future.value("adb");
    }
  }

  Future<String> getTempFilePathPath() async {
    if (Platform.isMacOS) {
      return channel.invokeMethod<String>('getDesktopPath');
    } else {
      var temp = await getTemporaryDirectory();
      return temp.absolute.path;
    }
  }
}
