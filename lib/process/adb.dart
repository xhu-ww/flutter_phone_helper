import 'dart:io';

import 'package:flutter_phone_helper/process/device.dart';

extension ProcessResultExt on ProcessResult {
  bool get isSuccess => this.exitCode == 0;
}

class ADB {
  ADB._();

  Future<ProcessResult> _execute(String arguments) {
    return Process.run('adb', arguments.split(' '));
  }

  /// adb devices
  Future<List<Device>> deviceIds() async {
    List<Device> devices = [];
    var result = await _execute("devices");
    if (result.isSuccess) {
      List<String> ids = [];
      result.stdout.split("\n").forEach((element) {
        if (element.isNotEmpty) ids.add(element.split("	").first);
      });
      ids.removeAt(0);

      var list = await Future.wait(ids.map((id) => Device(id).init()).toList());
      list.forEach((element) {
        if (element is Device) devices.add(element);
      });
    }
    return devices;
  }

  /// adb connect $ip:5555
  Future<bool> connectDeviceByIp(String ip) async {
    var result = await _execute("connect $ip:5555");
    return result.isSuccess;
  }

  /// adb pull
  Future<bool> pull({
    required String phoneFilePath,
    required String deskTopFilePath,
  }) async {
    var result = await _execute(
        "pull ${phoneFilePath.trim()} ${deskTopFilePath.trim()}");
    return result.isSuccess;
  }

  /// adb push
  Future<bool> push({
    required String deskTopFilePath,
    required String phoneFilePath,
  }) async {
    var result = await _execute(
        "push ${deskTopFilePath.trim()} ${phoneFilePath.trim()}");
    return result.isSuccess;
  }

  /// adb delete
  Future<bool> delete(String phoneFilePath) async {
    var result = await _execute("rm $phoneFilePath");
    return result.isSuccess;
  }
}

final adb = ADB._();
