import 'dart:io';

import 'package:flutter_phone_helper/channel/file_channel.dart';

// String adb;
// Directory storeFolderDirectory;
// Map<String, String> environment;
const scrcpyPath = "/usr/local/bin/scrcpy";
const brewPath = "/usr/local/Homebrew/bin/brew";

Future<void> initADB() async {
  final fileChannel = FileChannel();
  await Future.wait([
    fileChannel.getResourcesADBPath(),
    fileChannel.getDesktopDirectory(),
    readSystemEnvironment(),
  ]).then((value) {
    // adb = value[0];
    // storeFolderDirectory = value[1];
    // environment = {"PATH": "${value[2]}:${File(adb).parent.absolute.path}"};
  });
}

Future<String> readSystemEnvironment() async {
  var shell = "/usr/libexec/path_helper";
  var environment = "";
  try {
    var result = await Process.run(shell, []);
    if (result.exitCode == 0) {
      environment = result.stdout
          .replaceAll("PATH=\"", "")
          .replaceAll("\"; export PATH;", "")
          .trim();
    }
  } catch (e) {
    print(e);
  }

  return environment;
}
