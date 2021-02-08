import 'dart:io';

import 'package:flutter_phone_helper/channel/file_channel.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<String> get apkStoreFolderPath => _createStoreFolderChildPath("Apks");

  Future<String> get tempApkFolderPath async {
    var tempDirectory = await getTemporaryDirectory();

    if (tempDirectory != null) {
      var apkFolder =
          "${tempDirectory.absolute.path}${Platform.pathSeparator}xhu_ww${Platform.pathSeparator}AndroidPhoneHelper${Platform.pathSeparator}CacheAPk${Platform.pathSeparator}";
      var directory = Directory(apkFolder);
      if (!directory.existsSync()) {
        await directory.create(recursive: true);
      }
      return apkFolder;
    }
    return Future.error("Unable to get the desktop path");
  }

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

  Future<ProcessResult> unzip({
    required String filePath,
    required targetPath,
  }) async {
    var directory = Directory(targetPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return Process.run('tar', ['zxvf', filePath, '-C', targetPath]);
  }

  Future<ProcessResult> delete(String filePath) {
    return Process.run('rm', [filePath]);
  }

  Future<ProcessResult> shareScreen(String deviceId) async {
    return Process.run("scrcpy", ["-s", deviceId]);
  }

  /// aapt dump badging ~.apk | grep application:\ label
  /// label icon launch_activity
  Future<Map<String, String>> dumpApk(String apkPath) async {
    var result = await Process.run("aapt", ["dump", "badging", apkPath]);
    var apkInfoMap = <String, String>{};
    var lines = result.stdout.split("\n").map((e) => e.trim()).toList();
    for (String line in lines) {
      if (line.startsWith('application:')) {
        var labelRegExpStr = RegExp(r"label='(.*?)'");
        var label = labelRegExpStr.firstMatch(line)?.group(1) ?? "";
        apkInfoMap["label"] = label;

        var iconRegExpStr = RegExp(r"icon='(.*?)'");
        var icon = iconRegExpStr.firstMatch(line)?.group(1) ?? "";
        apkInfoMap["icon"] = icon;
        print(line);
      }

      if (line.startsWith('launchable-activity:')) {
        var regExpStr = RegExp(r"name='(.*?)'");
        var launchActivity = regExpStr.firstMatch(line)?.group(1) ?? "";
        apkInfoMap["launchActivity"] = launchActivity;
      }
    }
    return apkInfoMap;
  }
}

final system = System._();
