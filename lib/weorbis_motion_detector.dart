library weorbis_motion_detector;

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

part 'models/motion_event.dart';

/// The main entry point for the motion detector plugin.
///
/// This class provides a simple API to access the device's motion activity.
/// It's recommended to create a single instance of this class for your application.
class MotionDetector {
  static const EventChannel _eventChannel =
      EventChannel('weorbis_motion_detector');

  static final MotionDetector _instance = MotionDetector._();

  /// Private constructor for the singleton pattern.
  MotionDetector._();

  /// Gets the singleton instance of [MotionDetector].
  factory MotionDetector() => _instance;

  /// A convenience helper to request the required motion activity permission.
  ///
  /// On Android, this requests `Permission.activityRecognition`.
  /// On iOS, this requests `Permission.sensors`, which corresponds to the
  /// "Motion & Fitness" permission. The OS will prompt the user automatically on
  /// the first use.
  ///
  /// Returns `true` if the permission is granted.
  static Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.request();
      return status.isGranted;
    } else {
      final status = await Permission.sensors.request();
      return status.isGranted;
    }
  }

  /// Returns a broadcast stream of [MotionEvent] updates.
  ///
  /// Each time the device's most probable activity changes, a new [MotionEvent]
  /// is emitted on this stream.
  ///
  /// Parameters:
  /// - [runForegroundService]: On Android, enables a foreground service to
  ///   receive updates when the app is in the background. Defaults to `true`.
  /// - [notificationTitle]: The title of the persistent notification for the
  ///   Android foreground service.
  /// - [notificationText]: The body text of the persistent notification.
  /// - [notificationIcon]: The name of the drawable resource for the notification
  ///   icon (e.g., 'ic_launcher'). Must be a valid Android drawable.
  /// - [notificationId]: The unique integer ID for the Android notification.
  /// - [notificationImportance]: The importance level for the Android notification
  ///   channel (1=Low, 2=Default, 3=High).
  /// - [androidUpdateIntervalMillis]: The desired interval in milliseconds for
  ///   activity detection on Android. Defaults to `5000`.
  Stream<MotionEvent> motionStream({
    bool runForegroundService = true,
    String notificationTitle = "Motion Detector is running",
    String notificationText = "Monitoring your activity in the background.",
    String notificationIcon = "ic_launcher",
    int notificationId = 197812504,
    int notificationImportance = 3, // Corresponds to IMPORTANCE_HIGH
    int androidUpdateIntervalMillis = 5000,
  }) {
    // A new stream is created on each call to ensure the latest configuration
    // is sent to the native side.
    return _eventChannel.receiveBroadcastStream({
      "foreground": runForegroundService,
      "notificationTitle": notificationTitle,
      "notificationText": notificationText,
      "notificationIcon": notificationIcon,
      "notificationId": notificationId,
      "notificationImportance": notificationImportance,
      "androidUpdateIntervalMillis": androidUpdateIntervalMillis,
    }).map((json) => MotionEvent.fromString(json));
  }

  /// Returns the single most recent [MotionEvent] without setting up a continuous stream.
  ///
  /// This is useful for getting the user's current state on-demand.
  /// On Android, this **does not** start the foreground service.
  Future<MotionEvent> getCurrentActivity({
    Duration timeout = const Duration(seconds: 8),
  }) {
    return motionStream(runForegroundService: false)
        .first
        .timeout(timeout, onTimeout: () => MotionEvent.unknown());
  }
}
