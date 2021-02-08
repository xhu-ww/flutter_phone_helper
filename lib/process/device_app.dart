import 'dart:io';

import 'package:flutter_phone_helper/process/device.dart';
import 'adb.dart';
import 'system.dart';

class DeviceApp {
  String appId;
  Device device;
  String? currentActivity;
  String? _launchActivity;
  String? _versionName;
  String? _versionCode;
  String? _sdk;
  List<String>? _permissions;
  String? _label;
  String? _icon;

  DeviceApp({
    required this.appId,
    required this.device,
    this.currentActivity,
  });

  String? get versionName => _versionName;

  String? get versionCode => _versionCode;

  String? get sdk => _sdk;

  String? get launchActivity => _launchActivity;

  String? get label => _label;

  String? get icon => _icon;

  List<String>? get permissions => _permissions;

  /// adb -s $deviceId shell dumpsys window | grep mCurrentFocus
  /// adb -s $deviceId shell dumpsys package $packageName
  Future<void> init() async {
    var result = await device.executeShellCommand("dumpsys package $appId");
    if (result.isSuccess) {
      var permissions = <String>[];
      var lines = result.stdout.split("\n").map((e) => e.trim()).toList();
      var requestedPermissionsSection = false;
      for (String line in lines) {
        if (line.startsWith("versionCode")) {
          var codeArray = line.split(" ");
          _versionCode = codeArray.first.replaceAll("versionCode=", "");
          var length = codeArray.length;
          if (length == 3) {
            _sdk = codeArray[1] + " " + codeArray[2];
          } else if (length == 2) {
            _sdk = codeArray[1];
          }
        } else if (line.startsWith("versionName")) {
          _versionName = line.replaceAll("versionName=", "");
        }

        if (!line.contains(".permission.")) {
          requestedPermissionsSection = false;
        }
        if (line.contains("requested permissions:")) {
          requestedPermissionsSection = true;
          continue;
        }
        if (requestedPermissionsSection) {
          var permissionName = line.replaceAll(":", "").trim();
          permissions.add(permissionName);
        }
      }
      _permissions = permissions;
      await analyzeApk();
    }
  }

  /// adb -s $deviceId shell pm clear $appId
  Future<bool> clearAppData() async {
    var shell = "pm clear $appId";
    var result = await device.executeShellCommand(shell);
    return result.isSuccess;
  }

  /// adb -s $deviceId shell am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:$appId
  Future<bool> openAppSettings() async {
    if (appId.isEmpty) return false;
    var shell =
        "am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:$appId";
    var result = await device.executeShellCommand(shell);
    return result.isSuccess;
  }

  /// adb -s $deviceId shell pm grant $appId $permission
  Future<void> grantPermissions() async {
    if (_permissions != null) {
      var futures = _permissions!
          .map((permission) =>
              device.executeShellCommand("pm grant $appId $permission"))
          .toList();
      await Future.wait(futures);
    }
  }

  /// -s $deviceId shell pm revoke $appId $permission
  Future<void> revokePermissions() async {
    if (_permissions != null) {
      var futures = _permissions!
          .map((permission) =>
              device.executeShellCommand("pm revoke $appId $permission"))
          .toList();
      await Future.wait(futures);
    }
  }

  /// adb -s $deviceId uninstall $appId
  Future<bool> uninstallApp() async {
    var shell = "uninstall $appId";
    var result = await device.executeShellCommand(shell);
    return result.isSuccess;
  }

  /// adb -s $deviceId shell pm path $appId
  /// adb pull
  Future<String?> exportApk({outPutPath}) async {
    var result = await device.executeShellCommand("pm path $appId");
    if (result.isSuccess) {
      var apkPath = result.stdout.replaceFirst("package:", "");

      var targetPath = outPutPath;
      if (outPutPath == null) {
        var apkFolder = await system.tempApkFolderPath;
        targetPath = "$apkFolder$appId.apk";
      }
      var isExists = await File(targetPath).exists();
      if (!isExists) {
        await adb.pull(phoneFilePath: apkPath, deskTopFilePath: targetPath);
      }
      return targetPath;
    }
    return null;
  }

  /// aapt dump badging ~.apk | grep application:\ label
  Future<void> analyzeApk({bool unzipApk = false}) async {
    var apkPath = await exportApk();
    print(apkPath);
    if (apkPath == null) return;
    var apkInfoMap = await system.dumpApk(apkPath);
    _launchActivity = apkInfoMap["launchActivity"];
    _label = apkInfoMap["label"];
    var icon = apkInfoMap["icon"];

    var parentPath = File(apkPath).parent.absolute.path;
    var targetPath =
        "$parentPath${Platform.pathSeparator}$appId${Platform.pathSeparator}";
    _icon = "$targetPath$icon";
    if (unzipApk) {
      await system.unzip(filePath: apkPath, targetPath: targetPath);
    }
  }
}
