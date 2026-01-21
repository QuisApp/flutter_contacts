import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class MethodCallLog {
  final List<MethodCall> calls = [];

  void add(MethodCall call) => calls.add(call);

  MethodCall get last => calls.last;

  void clear() => calls.clear();
}

Future<MethodCallLog> setUpMockMethodChannel(
  MethodChannel channel, {
  Future<dynamic> Function(MethodCall call)? handler,
}) async {
  final log = MethodCallLog();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
        log.add(call);
        return handler?.call(call);
      });
  return log;
}
