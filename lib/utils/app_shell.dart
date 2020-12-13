import 'dart:core';

import 'package:flutter_phone_helper/data/app_info.dart';

import 'shell.dart';

Future getAppInfo(String deviceId) async {
  var appResult = await executeShell(
      "adb -s $deviceId shell dumpsys window | grep mCurrentFocus");
  if (appResult.isSuccess()) {
    var packageStdout = appResult.stdout.split("\n").first;
    var array = packageStdout.split("/");
    if (array.length == 2) {
      var packageName = array[0].split(" ").last.trim();
      var activityName = array[1].replaceAll("}", "").trim();
      String versionCode = "";
      String versionName = "";
      String sdk = "";
      List<String> permissions = [];

      var packageInfoResult = await executeShell(
          "adb -s $deviceId shell dumpsys package $packageName");
      if (packageInfoResult.isSuccess()) {
        var lines =
            packageInfoResult.stdout.split("\n").map((e) => e.trim()).toList();

        var requestedPermissionsSection = false;

        for (String line in lines) {
          if (line.startsWith("versionCode")) {
            var codeArray = line.split(" ");
            versionCode = codeArray.first.replaceAll("versionCode=", "");
            var length = codeArray.length;
            if (length == 3) {
              sdk = codeArray[1] + " " + codeArray[2];
            } else if (length == 2) {
              sdk = codeArray[1];
            }
          } else if (line.startsWith("versionName")) {
            versionName = line.replaceAll("versionName=", "");
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
      }

      return AppInfo(
        appId: packageName,
        currentActivity: activityName,
        versionCode: versionCode,
        versionName: versionName,
        sdk: sdk,
        permissions: permissions,
      );
    }
  }
  return null;
}

Future<bool> clearAppData(String deviceId, String appId) async {
  if (appId?.isEmpty ?? true) return false;
  var shell = "adb -s $deviceId shell pm clear $appId";
  var result = await executeShell(shell);
  return result.isSuccess();
}

Future<bool> openAppSettings(String deviceId, String appId) async {
  if (appId?.isEmpty ?? true) return false;
  var shell =
      "adb -s $deviceId shell am start -a android.settings.APPLICATION_DETAILS_SETTINGS -d package:$appId";
  var result = await executeShell(shell);
  return result.isSuccess();
}

Future grantPermissions(String deviceId, AppInfo appInfo) async {
  var futures = appInfo?.permissions?.map((e) {
    var shell = "adb -s $deviceId shell pm grant ${appInfo.appId} $e";
    return executeShell(shell);
  })?.toList();

  await Future.wait(futures);
}

Future revokePermissions(String deviceId, AppInfo appInfo) async {
  var futures = appInfo?.permissions?.map((e) {
    var shell = "adb -s $deviceId shell pm revoke ${appInfo.appId} $e";
    return executeShell(shell);
  })?.toList();

  var results = await Future.wait(futures);
  return results.map((e) => e.isSuccess()).any((element) => true);
}

Future<bool> uninstallApp(String deviceId, String appId) async {
  if (appId?.isEmpty ?? true) return false;
  var shell = "adb -s $deviceId uninstall $appId";
  var result = await executeShell(shell);
  return result.isSuccess();
}
