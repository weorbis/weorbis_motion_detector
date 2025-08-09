# WeOrbis Motion Detector

[](https://pub.dev/packages/weorbis_motion_detector)

A Flutter plugin for Android and iOS that provides access to the device's motion activity. It streams activity updates like `STILL`, `WALKING`, `RUNNING`, `IN_VEHICLE`, etc., detected by the phone's hardware.

This package is a modernized fork of the original `activity_recognition_flutter` plugin and works while the app is running in the foreground or background.

-----

## Features

\-   Provides a continuous stream of motion activity updates.
\-   Supports running as a foreground service on Android for continuous background monitoring.

  - **Configurable update interval** on Android to balance battery life and responsiveness.
  - **Convenience helpers** for permission requests and one-shot activity fetching.
    \-   Simple and lightweight API.

-----

## Platform Support

| Platform | Support |
| --- | --- |
| Android | ✅ |
| iOS     | ✅ |

-----

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  weorbis_motion_detector: ^1.1.1
```

Then, run `flutter pub get` to install the package.

-----

## Configuration

### Android

Android is plug-and-play by default. No manual changes to `AndroidManifest.xml` are required for common use cases — the plugin provides the required permissions and components via manifest merging.

Notes:

  - On Android 10+ you must request the runtime permission for `ACTIVITY_RECOGNITION`. Use `MotionDetector.requestPermission()` (see Usage below).
  - Foreground service will only run if you opt in via `runForegroundService: true` when starting the stream.

Optional: Manual override (only if you need to customize or opt out of defaults)

If your app needs to explicitly declare or override the merged settings, add the following to your app manifest.

**File**: `android/app/src/main/AndroidManifest.xml`

1. Inside the `<manifest>` tag:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

2. Inside the `<application>` tag:

```xml
<receiver
    android:name="com.weorbis.motion_detector.ActivityRecognizedBroadcastReceiver"
    android:exported="false" />
<service
    android:name="com.weorbis.motion_detector.ForegroundService"
    android:exported="false" />
```

### iOS

An iOS app built for iOS 10.0 or later must include a usage description key in its `Info.plist` file for the types of data it needs to access. Failure to include this key will cause the app to crash.

To access motion data, add the `NSMotionUsageDescription` key to your `Info.plist` file:

**File**: `ios/Runner/Info.plist`

```xml
<key>NSMotionUsageDescription</key>
<string>This app needs to access your motion data to detect your activity.</string>
```

-----

## Usage

### 1\. Requesting Permission

First, use the convenient built-in helper to request the necessary permissions.

```dart
import 'package:weorbis_motion_detector/weorbis_motion_detector.dart';

bool isPermissionGranted = await MotionDetector.requestPermission();
if (isPermissionGranted) {
  // Proceed to start listening to motion updates.
} else {
  // Handle the case where the user denies the permission.
}
```

Note on one-shot behavior

  - `getCurrentActivity()` performs a single check and resolves once.
  - It does not start or keep a foreground service running.
  - On Android, it returns the best available current (or most recent) recognized activity, depending on sensor availability at call time.

### 2\. Listening to the Motion Stream

To get a continuous stream of updates, use `motionStream()`. This is ideal for apps that need to constantly react to changes in user activity.

```dart
StreamSubscription<MotionEvent>? streamSubscription;
final MotionDetector _motionDetector = MotionDetector();

void startStreaming() {
  streamSubscription = _motionDetector.motionStream(
    // Optional: Check every 10 seconds on Android
    androidUpdateIntervalMillis: 10000, 
  ).listen((MotionEvent event) {
    print('New Stream Event: ${event.type} (${event.confidence}%)');
  });
}

// Don't forget to cancel the subscription when you're done!
@override
void dispose() {
  streamSubscription?.cancel();
  super.dispose();
}
```

### 3\. Getting a Single "On-Demand" Update

If you only need to know the user's current activity once, use `getCurrentActivity()`.

```dart
final MotionDetector _motionDetector = MotionDetector();

void checkCurrentActivity() async {
  try {
    MotionEvent event = await _motionDetector.getCurrentActivity();
    print('Current Activity: ${event.type} (${event.confidence}%)');
  } catch (e) {
    print("Error getting current activity: $e");
  }
}
```

### The `MotionEvent` Model

The stream returns `MotionEvent` objects with the following properties:

  * **`type`**: An `enum` (`MotionType`) representing the detected activity.
  * **`confidence`**: An `int` (0-100) representing the confidence of the detection.
  * **`timeStamp`**: A `DateTime` object for when the event was created.

The possible `MotionType` values are:

  * `IN_VEHICLE`
  * `ON_BICYCLE`
  * `ON_FOOT`
  * `RUNNING`
  * `STILL`
  * `TILTING`
  * `WALKING`
  * `UNKNOWN`
  * `INVALID` (used for parsing errors)

### Android Foreground Service Configuration

You can customize the persistent notification that appears when running in the background on Android.

```dart
motionDetector.motionStream(
  runForegroundService: true,
  notificationTitle: "Motion Activity",
  notificationText: "Monitoring your activity to provide great features.",
  // IMPORTANT: 'notificationIcon' must be a valid drawable resource
  // located in `your_android_project/app/src/main/res/drawable/`.
  // Do not include the file extension.
  notificationIcon: "my_custom_notification_icon",
);
```

### iOS Confidence Note

On iOS, the native API provides confidence as an enum (`low`, `medium`, `high`). This plugin maps them to integer values to align with Android:

  * `low` = **10%**
  * `medium` = **50%**
  * `high` = **100%**

-----

## Contributing

Contributions are welcome\! Please feel free to submit a pull request or open an issue.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/weorbis/weorbis_motion_detector/blob/main/LICENSE) file for details.
