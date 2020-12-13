import 'package:process_runner/process_runner.dart';

class ShellResult extends ProcessRunnerResult {
  ShellResult(int exitCode, List<int> stdoutRaw, List<int> stderrRaw,
      List<int> outputRaw)
      : super(exitCode, stdoutRaw, stderrRaw, outputRaw);

  bool isSuccess() => exitCode == 0;

  static ShellResult convertToShellResult(ProcessRunnerResult result) {
    return ShellResult(
      result.exitCode,
      result.stdoutRaw,
      result.stderrRaw,
      result.outputRaw,
    );
  }
}
