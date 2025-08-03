library weorbis_motion_detector;

import 'dart:async';

import 'package:flutter/services.dart';

part 'motion_detector_domain.dart';

/// Main entry to activity recognition API. Use as a singleton like
///
///   `MotionDetector()`
///
class MotionDetector {
  static const EventChannel _eventChannel =
      const EventChannel('weorbis_motion_detector');
  Stream<ActivityEvent>? _stream;
  static MotionDetector _instance = MotionDetector._();
  MotionDetector._();

  /// Get the [MotionDetector] singleton.
  factory MotionDetector() => _instance;

  /// Requests continuous [ActivityEvent] updates.
  ///
  /// The Stream will output the *most probable* [ActivityEvent].
  /// By default the foreground service is enabled, which allows the
  /// updates to be streamed while the app runs in the background.
  /// The programmer can choose to not enable to foreground service.
  Stream<ActivityEvent> activityStream({bool runForegroundService = true}) {
    if (_stream == null) {
      _stream = _eventChannel
          .receiveBroadcastStream({"foreground": runForegroundService}).map(
              (json) => ActivityEvent.fromString(json));
    }
    return _stream!;
  }
}
