import 'dart:io';

import 'package:flutter_phone_helper/channel/file_channel.dart';
import 'package:flutter_phone_helper/data/shell_result.dart';
import 'package:process_runner/process_runner.dart';

String adb;
Directory storeFolderDirectory;
Map<String, String> environment;
const scrcpyPath = "/usr/local/bin/scrcpy";
const brewPath = "/usr/local/Homebrew/bin/brew";

Future<void> initADB() async {
  final fileChannel = FileChannel();
  await Future.wait([
    fileChannel.getResourcesADBPath(),
    fileChannel.getStoreFolderPath(),
    readSystemEnvironment(),
  ]).then((value) {
    adb = value[0];
    storeFolderDirectory = value[1];
    environment = {"PATH": "${value[2]}:${File(adb).parent.absolute.path}"};
  });
}

Future<String> readSystemEnvironment() async {
  var shell = "/usr/libexec/path_helper";
  var environment = "";
  try {
    var result = await ProcessRunner().runProcess([shell]);
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

Future<ShellResult> executeShell(String shell) async {
  shell = shell.replaceFirst("adb", adb);
  var result = await ProcessRunner(environment: environment)
      .runProcess(shell.split(" "));
  return ShellResult.convertToShellResult(result);
}

void openFile(String path) async {
  if (path == null) return;
  var shell = Platform.isMacOS ? "open $path" : path;
  await executeShell(shell);
}

Future<ShellResult> downloadScrcpy() {
  return executeShell("$brewPath install scrcpy");
}

Future<String> createScreenFile() async {
  if (storeFolderDirectory == null) {
    storeFolderDirectory = await FileChannel().getStoreFolderPath();
  }

  if (!storeFolderDirectory.existsSync()) {
    storeFolderDirectory.create();
  }
  return storeFolderDirectory.absolute.path;
}
