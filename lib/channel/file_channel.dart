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

  Future<Directory> getStoreFolderPath() async {
    var path = "";
    if (Platform.isMacOS) {
      var desktop = await channel.invokeMethod<String>('getDesktopPath');
      path = "$desktop${Platform.pathSeparator}截屏和录屏";
    } else {
      var tempDirectory = await getTemporaryDirectory();
      path =
          "${tempDirectory.absolute.path}${Platform.pathSeparator}phone_helper_temp";
    }
    return Directory(path);
  }
}
