import 'dart:io';

Future<ProcessResult> shareScreen(String deviceId) async {
  return Process.run("scrcpy", ["-s", deviceId]);
}
