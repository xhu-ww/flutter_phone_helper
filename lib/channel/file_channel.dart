import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FileChannel {
  final MethodChannel channel = MethodChannel('plugins.flutter.file_channel');

  Future<String?> getResourcesADBPath() {
    if (Platform.isMacOS) {
      return channel.invokeMethod<String>('getResourcesADBPath');
    } else {
      return Future.value("adb");
    }
  }

  Future<Directory> getDesktopDirectory() async {
    if (Platform.isMacOS) {
      var desktop = await channel.invokeMethod<String>('getDesktopPath');
      if (desktop != null) {
        return Directory(desktop);
      }
    }
    var directory = await getTemporaryDirectory();
    if (directory == null) {
      return Future.error("Unable to get the desktop path");
    }
    return directory;
  }
}
