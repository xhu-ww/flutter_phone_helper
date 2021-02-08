import 'dart:collection';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_phone_helper/process/adb.dart';
import 'package:flutter_phone_helper/process/device_app.dart';
import 'package:flutter_phone_helper/process/system.dart';

class Device {
  String id;

  String? _name;
  String? _ip;
  String? _abiList;
  String? _versionName;
  String? _sdk;
  String? _physicalSize;
  String? _density;
  bool _connectedByWifi = false;

  Device(this.id);

  String? get name => _name;

  String? get ip => _ip;

  String? get abiList => _abiList;

  String? get versionName => _versionName;

  String? get sdk => _sdk;

  String? get physicalSize => _physicalSize;

  String? get density => _density;

  bool get connectedByWifi => _connectedByWifi;

  Future<ProcessResult> executeShellCommand(String shell) {
    var arguments = ['-s', id, 'shell']..addAll(shell.split(' '));
    return Process.run('adb', arguments);
  }

  /// adb -s $deviceId shell getprop
  Future<void> init() async {
    var result = await executeShellCommand("getprop");
    if (result.isSuccess) {
      List<String> lines =
          result.stdout.replaceAll(RegExp(r"\[|\]"), "").split("\n");
      Map<String, String> messages = HashMap();

      for (String line in lines) {
        final array = line.split(":");
        messages[array.first] = array.last;
      }
      _connectedByWifi = id.endsWith("5555");
      _name =
          "${messages["ro.product.brand"] ?? ""},${messages["ro.product.model"] ?? ""}";
      _abiList = messages["ro.product.cpu.abilist"] ??
          "${messages["ro.product.cpu.abi2"] ?? ""}${messages["ro.product.cpu.abi"] ?? ""}";
      _versionName = messages["ro.build.version.release"];
      _sdk = messages["ro.build.version.sdk"];
      _density = messages["ro.sf.lcd_density"];

      var values = await Future.wait([deviceIp(), devicePhysicalSize()]);
      _ip = values.first;
      _physicalSize = values.last;
    }
  }

  /// adb -s $deviceId shell wm size
  Future<String?> devicePhysicalSize() async {
    var result = await executeShellCommand("wm size");
    if (result.isSuccess) {
      try {
        return result.stdout.split(":").last.trim();
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return null;
  }

  /// adb -s $deviceId shell ip route
  Future<String?> deviceIp() async {
    var result = await executeShellCommand("ip route");
    if (result.isSuccess) {
      //192.168.104.0/24 dev wlan0  proto kernel  scope link  src 192.168.104.226
      try {
        var realIpData = result.stdout.split("src").last;
        var regExpStr = RegExp(
            r'((2(5[0-5]|[0-4]\d))|1?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|1?\d{1,2})){3}');
        return regExpStr.stringMatch(realIpData);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return null;
  }

  /// adb -s $deviceId tcpip 5555
  Future<bool> openTcpConnect() async {
    var result = await executeShellCommand("tcpip 5555");
    return result.isSuccess;
  }

  /// adb -s $deviceId disconnect $ip:5555
  Future<bool> disconnectWifi() async {
    var currentIp = await deviceIp();
    if (currentIp == null) return false;
    var result = await executeShellCommand("disconnect $currentIp:5555");
    return result.isSuccess;
  }

  Future<bool> connectWifi() async {
    var canConnect = await openTcpConnect();
    var currentIp = await deviceIp();
    if (canConnect && currentIp != null) {
      return await adb.connectDeviceByIp(currentIp);
    }
    return false;
  }

  /// adb -s $deviceId shell am start -a android.intent.action.VIEW -d $urlScheme
  Future<bool> openLink(String url) async {
    var urlScheme = !url.contains("://") ? "https://$url" : url;
    var shell = "am start -a android.intent.action.VIEW -d $urlScheme";
    var result = await executeShellCommand(shell);
    return result.isSuccess;
  }

  /// adb -s $deviceId shell screencap /sdcard/$imageName
  /// return saved file path
  Future<String?> screenshot() async {
    var imageName = "${DateTime.now().millisecondsSinceEpoch}.png";
    var imagePhonePath = "/sdcard/$imageName";
    var result = await executeShellCommand("screencap $imagePhonePath");
    if (result.isSuccess) {
      var folder = await system.imageStoreFolderPath;
      await adb.pull(phoneFilePath: imagePhonePath, deskTopFilePath: folder);
      await adb.delete(imagePhonePath);
      return "$folder$imageName";
    }
    return null;
  }

  /// adb -s $deviceId shell screenrecord --verbose --bit-rate $rateString --size $size /sdcard/$videoName
  /// return saved file path
  Future<String> screenRecord({
    int rate = 4,
    int width = 720,
    int height = 1280,
  }) async {
    var videoName = "${DateTime.now().millisecondsSinceEpoch}.mp4";
    var videoPhonePath = "/sdcard/$videoName";
    var rateString = ((rate) * 1000000).toString();
    var size = "$width x $height";
    var shell =
        "screenrecord --verbose --bit-rate $rateString --size $size $videoPhonePath";
    try {
      await executeShellCommand(shell);
    } catch (e) {
      print(e);
    }

    var folder = await system.videoStoreFolderPath;
    await adb.pull(phoneFilePath: videoPhonePath, deskTopFilePath: folder);
    await adb.delete(videoPhonePath);
    return "$folder$videoPhonePath";
  }

  /// adb -s $deviceId shell pkill -l 2 screenrecord
  Future<void> stopScreenRecord() async {
    await executeShellCommand("pkill -l 2 screenrecord");
  }

  /// adb -s $deviceId shell dumpsys window | grep mCurrentFocus
  /// adb -s $deviceId shell dumpsys package $packageName
  Future<DeviceApp> currentFocusApp() async {
    var appResult =
        await executeShellCommand("dumpsys window | grep mCurrentFocus");
    if (appResult.isSuccess) {
      var packageStdout = appResult.stdout.split("\n").first;
      var array = packageStdout.split("/");
      if (array.length == 2) {
        var packageName = array[0].split(" ").last.trim();
        var activityName = array[1].replaceAll("}", "").trim();
        var app = DeviceApp(
          appId: packageName,
          device: this,
          currentActivity: activityName,
        );
        await app.init();
        return app;
      }
    }
    return Future.error('Unable to get App');
  }

  Future<List<String>> allAppIds() async {
    var appResult = await executeShellCommand("pm list packages -3");
    var packages = <String>[];
    if (appResult.isSuccess) {
      var lines = appResult.stdout.split("\n").first;
      for (String line in lines) {
        var package = line.replaceFirst("package:", "");
        packages.add(package);
      }
    }
    return packages;
  }
}
