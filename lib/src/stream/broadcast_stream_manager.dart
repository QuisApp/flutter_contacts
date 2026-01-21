import 'dart:async';
import 'package:flutter/services.dart';

/// Manages a single platform stream and broadcasts it to multiple Dart listeners.
class BroadcastStreamManager<T> {
  final EventChannel _eventChannel;
  final T Function(dynamic)? _transform;
  StreamSubscription<dynamic>? _platformSubscription;
  StreamController<T>? _broadcastController;

  BroadcastStreamManager(this._eventChannel, {T Function(dynamic)? transform})
    : _transform = transform;

  Stream<T> get stream {
    _broadcastController ??= StreamController<T>.broadcast(
      onListen: _ensurePlatformStream,
      onCancel: _cancelPlatformStream,
    );
    return _broadcastController!.stream;
  }

  void _ensurePlatformStream() {
    if (_platformSubscription != null) return;

    _platformSubscription = _eventChannel.receiveBroadcastStream().listen(
      (event) {
        final transformed = _transform?.call(event) ?? event as T;
        _broadcastController?.add(transformed);
      },
      onDone: _cancelPlatformStream,
      cancelOnError: false,
    );
  }

  void _cancelPlatformStream() {
    _platformSubscription?.cancel();
    _platformSubscription = null;
  }
}
