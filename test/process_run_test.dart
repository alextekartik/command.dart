@TestOn("vm")
library command.test.process_run_test_;

import 'dart:io';
import 'package:dev_test/test.dart';
import 'package:command/dartbin.dart';
import 'package:path/path.dart';
import 'package:command/process_run.dart';
import 'process_run_test_common.dart';
import 'dart:async';
import 'dart:convert';

void main() {
  Future _runCheck(check(Result), String executable, List<String> arguments,
      {String workingDirectory,
      Map<String, String> environment,
      includeParentEnvironment: true,
      bool runInShell: false,
      stdoutEncoding: SYSTEM_ENCODING,
      stderrEncoding: SYSTEM_ENCODING,
      connectStdout: false,
      connectStderr: false,
      connectStdin: false}) async {
    ProcessResult result = await Process.run(executable, arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        runInShell: runInShell,
        stdoutEncoding: stdoutEncoding,
        stderrEncoding: stderrEncoding);
    check(result);
    result = await run(executable, arguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        runInShell: runInShell,
        stdoutEncoding: stdoutEncoding,
        stderrEncoding: stderrEncoding,
        connectStderr: connectStderr,
        connectStdout: connectStdout,
        connectStdin: connectStdin);
    check(result);
  }

  test('stdout', () async {
    checkOut(ProcessResult result) {
      expect(result.stderr, '');
      expect(result.stdout, "out");
      expect(result.pid, isNotNull);
      expect(result.exitCode, 0);
    }
    checkEmpty(ProcessResult result) {
      expect(result.stderr, '');
      expect(result.stdout, '');
      expect(result.pid, isNotNull);
      expect(result.exitCode, 0);
    }
    await _runCheck(
        checkOut, dartExecutable, [echoScriptPath, '--stdout', 'out']);
    await _runCheck(checkEmpty, dartExecutable, [echoScriptPath]);
  });

  test('stdout_bin', () async {
    check123(ProcessResult result) {
      expect(result.stderr, '');
      expect(result.stdout, [1, 2, 3]);
      expect(result.pid, isNotNull);
      expect(result.exitCode, 0);
    }
    checkEmpty(ProcessResult result) {
      expect(result.stderr, '');
      expect(result.stdout, []);
      expect(result.pid, isNotNull);
      expect(result.exitCode, 0);
    }
    await _runCheck(
        check123, dartExecutable, [echoScriptPath, '--stdout-hex', '010203'],
        stdoutEncoding: null);
    await _runCheck(checkEmpty, dartExecutable, [echoScriptPath],
        stdoutEncoding: null);
  });

  test('stderr', () async {
    checkErr(ProcessResult result) {
      expect(result.stdout, '');
      expect(result.stderr, "err");
      expect(result.pid, isNotNull);
      expect(result.exitCode, 0);
    }
    checkEmpty(ProcessResult result) {
      expect(result.stderr, '');
      expect(result.stdout, '');
      expect(result.pid, isNotNull);
      expect(result.exitCode, 0);
    }
    await _runCheck(
        checkErr, dartExecutable, [echoScriptPath, '--stderr', 'err'],
        connectStdout: true);
    await _runCheck(checkEmpty, dartExecutable, [echoScriptPath]);
  });

  test('stderr_bin', () async {
    check123(ProcessResult result) {
      expect(result.stdout, '');
      expect(result.stderr, [1, 2, 3]);
      expect(result.pid, isNotNull);
      expect(result.exitCode, 0);
    }
    checkEmpty(ProcessResult result) {
      expect(result.stdout, '');
      expect(result.stderr, []);
      expect(result.pid, isNotNull);
      expect(result.exitCode, 0);
    }
    await _runCheck(
        check123, dartExecutable, [echoScriptPath, '--stderr-hex', '010203'],
        stderrEncoding: null);
    await _runCheck(checkEmpty, dartExecutable, [echoScriptPath],
        stderrEncoding: null);
  });

  test('exitCode', () async {
    check123(ProcessResult result) {
      expect(result.stdout, '');
      expect(result.stderr, '');
      expect(result.pid, isNotNull);
      expect(result.exitCode, 123);
    }
    check0(ProcessResult result) {
      expect(result.stdout, '');
      expect(result.stderr, '');
      expect(result.pid, isNotNull);
      expect(result.exitCode, 0);
    }
    await _runCheck(
        check123, dartExecutable, [echoScriptPath, '--exit-code', '123']);
    await _runCheck(check0, dartExecutable, [echoScriptPath]);
  });

  test('crash', () async {
    check(ProcessResult result) {
      expect(result.stdout, '');
      expect(result.stderr, isNotEmpty);
      expect(result.pid, isNotNull);
      expect(result.exitCode, 255);
    }

    await _runCheck(
        check, dartExecutable, [echoScriptPath, '--exit-code', 'crash']);
  });

  test('no_argument', () async {
    try {
      await Process.run(dartExecutable, null);
    } on ArgumentError catch (_) {
      // Invalid argument(s): Arguments is not a List: null
    }
    try {
      await run(dartExecutable, null);
    } on ArgumentError catch (_) {
      // Invalid argument(s): Arguments is not a List: null
    }
  });

  test('invalid_executable', () async {
    try {
      await Process.run(dummyExecutable, []);
    } on ProcessException catch (_) {
      // ProcessException: No such file or directory
    }

    try {
      await run(dummyExecutable, []);
    } on ProcessException catch (_) {
      // ProcessException: No such file or directory
    }
  });

  test('system_command', () async {
    // read pubspec.yaml
    List<String> lines = const LineSplitter().convert(
        await new File(join(dirname(testDir), 'pubspec.yaml')).readAsString());

    check(ProcessResult result) {
      expect(const LineSplitter().convert(result.stdout), lines);
      expect(result.stderr, '');
      expect(result.pid, isNotNull);
      expect(result.exitCode, 0);
    }

    // use 'cat' on mac and linux
    // use 'type' on windows

    if (Platform.isWindows) {
      await _runCheck(check, 'type', ['pubspec.yaml'],
          workingDirectory: dirname(testDir));
    } else {
      await _runCheck(check, 'cat', ['pubspec.yaml'],
          workingDirectory: dirname(testDir));
    }
  });
}
