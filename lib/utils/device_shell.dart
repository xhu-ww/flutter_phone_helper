import 'dart:collection';
import 'dart:io';

import 'package:flutter_phone_helper/data/device.dart';
import 'package:flutter_phone_helper/data/shell_result.dart';
import 'shell.dart';

Future<List<Device>> getConnectedDevices() async {
  var result = await executeShell("adb devices");
  List<Device> devices = [];

  if (result.exitCode == 0) {
    List<String> ids = [];

    /// data
    /// List of devices attached
    /// 192.168.104.67:5555	device

    result.stdout.split("\n").forEach((element) {
      if (element.isNotEmpty) ids.add(element.split("	").first);
    });
    ids.removeAt(0);
    var list = await Future.wait(ids.map(getDeviceDetail).toList());
    for (Device device in list) {
      if (device != null) {
        devices.add(device);
      }
    }
  }
  return devices;
}

Future<Device> getDeviceDetail(String deviceId) async {
  Device device;
  try {
    var physicalSize = await getDevicePhysicalSize(deviceId);
    var result = await executeShell("adb -s $deviceId shell getprop");

    if (result.isSuccess()) {
      List<String> lines =
          result.stdout.replaceAll(RegExp(r"\[|\]"), "").split("\n");
      Map<String, String> messages = HashMap();

      for (String line in lines) {
        final array = line.split(":");
        messages[array.first] = array.last;
      }

      var abiList = messages["ro.product.cpu.abilist"];
      if (abiList?.isEmpty ?? true) {
        abiList =
            "${messages["ro.product.cpu.abi2"] ?? ""}${messages["ro.product.cpu.abi"] ?? ""}";
      }

      device = Device(
        id: deviceId,
        name:
            "${messages["ro.product.brand"] ?? ""},${messages["ro.product.model"] ?? ""}",
        abiList: abiList,
        versionName: messages["ro.build.version.release"],
        sdk: messages["ro.build.version.sdk"],
        physicalSize: " $physicalSize",
        density: messages["ro.sf.lcd_density"],
      );
      device.connectedByWifi = deviceId.endsWith("5555");
    }
  } catch (e) {
    print(e);
  }
  return device;
}

Future<String> getDevicePhysicalSize(String deviceId) async {
  var result = await executeShell("adb -s $deviceId shell wm size");
  String size = "";
  if (result.isSuccess()) {
    try {
      size = result.stdout.split(":").last.trim();
    } catch (e) {
      print(e);
    }
  }
  return size;
}

Future<String> getDeviceIp(String deviceId) async {
  var ipResult = await executeShell("adb -s $deviceId shell ip route");
  String ip = "";
  if (ipResult.isSuccess()) {
    //192.168.104.0/24 dev wlan0  proto kernel  scope link  src 192.168.104.226
    try {
      var realIpData = ipResult.stdout.split("src").last;
      var regExpStr = new RegExp(
          r'((2(5[0-5]|[0-4]\d))|1?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|1?\d{1,2})){3}');
      ip = regExpStr.stringMatch(realIpData);
    } catch (e) {
      print(e);
    }
  }
  return ip;
}

Future<bool> disconnectWifi(String deviceId) async {
  var ip = await getDeviceIp(deviceId);
  if (ip?.isEmpty ?? true) return false;

  var connectResult =
      await executeShell("adb -s $deviceId disconnect $ip:5555");
  return connectResult.isSuccess();
}

Future<bool> connectWifi(String deviceId) async {
  var ip = await openTcpConnect(deviceId);
  if (ip?.isEmpty ?? true) return false;
  return await connectDeviceByIp(ip);
}

Future<String> openTcpConnect(String deviceId) async {
  var ip = await getDeviceIp(deviceId);
  if (ip != null) {
    var tcpResult = await executeShell("adb -s $deviceId tcpip 5555");
    if (tcpResult.isSuccess()) return ip;
  }
  return null;
}

Future<bool> connectDeviceByIp(String ip) async {
  if (ip?.isEmpty ?? true) return false;
  var connectResult = await executeShell("adb connect $ip:5555");
  return connectResult.isSuccess();
}

Future<ShellResult> shareScreen(String deviceId) async {
  return executeShell("$scrcpyPath -s $deviceId");
}

Future<bool> openLink(String deviceId, String url) async {
  var urlScheme = !url.contains("://") ? "https://$url" : url;
  var shell =
      "adb -s $deviceId shell am start -a android.intent.action.VIEW -d $urlScheme";
  var result = await executeShell(shell);
  return result.isSuccess();
}

Future<String> screenshot(String deviceId) async {
  var imageName = "${DateTime.now().millisecondsSinceEpoch}.png";
  var screenshotShell = "adb -s $deviceId shell screencap /sdcard/$imageName";
  var screenshotResult = await executeShell(screenshotShell);
  if (screenshotResult.isSuccess()) {
    return _saveScreenFile(deviceId, imageName);
  }
  return null;
}

Future<String> screenRecord({
  String deviceId,
  int rate = 4,
  int width = 720,
  int height = 1280,
}) async {
  var videoName = "${DateTime.now().millisecondsSinceEpoch}.mp4";
  var rateString = ((rate ?? 4) * 1000000).toString();
  var size = "${width ?? 1280}x${height ?? 720}";
  var screenshotShell =
      "adb -s $deviceId shell screenrecord --verbose --bit-rate $rateString --size $size /sdcard/$videoName";
  try {
    await executeShell(screenshotShell);
  } catch (e) {
    print(e);
  }
  return _saveScreenFile(deviceId, videoName);
}

void stopScreenRecord(String deviceId) async {
  await executeShell("adb -s $deviceId shell pkill -l 2 screenrecord");
}

Future<String> _saveScreenFile(String deviceId, String fileName) async {
  var saveFile = await createScreenFile();
  var pullShell = "adb -s $deviceId pull /sdcard/$fileName $saveFile";
  await executeShell(pullShell);
  var deleteShell = "adb -s $deviceId shell rm /sdcard/$fileName";
  executeShell(deleteShell);
  return "$saveFile${Platform.pathSeparator}$fileName";
}
