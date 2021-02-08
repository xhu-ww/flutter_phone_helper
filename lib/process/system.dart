import 'dart:io';

import 'package:flutter_phone_helper/channel/file_channel.dart';

class System {
  System._();

  String? _storeFolderPath;

  Future<String> get storeFolderPath async {
    if (_storeFolderPath == null) {
      var deskTop = await FileChannel().getDesktopDirectory();
      _storeFolderPath =
          "${deskTop.absolute.path}${Platform.pathSeparator}AndroidPhoneHelper";
    }
    return _storeFolderPath!;
  }

  Future<String> _createStoreFolderChildPath(String type) async {
    var path = await storeFolderPath;
    var typeFolderPath =
        "$path${Platform.pathSeparator}$type${Platform.pathSeparator}";
    var directory = Directory(typeFolderPath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    return typeFolderPath;
  }

  Future<String> get imageStoreFolderPath =>
      _createStoreFolderChildPath("Screenshot_Image");

  Future<String> get videoStoreFolderPath =>
      _createStoreFolderChildPath("Screenshot_Video");

  Future<String> get apkStoreFolderPath =>
      _createStoreFolderChildPath("Cache_Apks");

  void openFile(String? path) async {
    if (path == null) return;
    if (Platform.isMacOS) {
      await Process.run('open', [path]);
    } else {
      await Process.run('path', []);
    }
  }

  Future<ProcessResult> downloadScrcpy() {
    return Process.run('brew', ['install', 'scrcpy']);
  }
}

final system = System._();
