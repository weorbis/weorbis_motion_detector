# WeOrbis Motion Detector

[![pub package](https://img.shields.io/pub/v/weorbis_motion_detector.svg)](https://pub.dev/packages/weorbis_motion_detector)

A Flutter plugin for Android and iOS that provides access to the device's motion activity. It streams activity updates like `STILL`, `WALKING`, `RUNNING`, `IN_VEHICLE`, etc., detected by the phone's hardware.

This package is a modernized fork of the original `activity_recognition_flutter` plugin and works while the app is running in the foreground or background.



---

## Features

-   Provides a continuous stream of motion activity updates.
-   Parses native activity types into a simple, unified `ActivityEvent` model.
-   Supports running as a foreground service on Android for continuous background monitoring.
-   Simple and lightweight API.

---

## Platform Support
| Platform | Support |
| --- | --- |
| Android | ✅ |
| iOS     | ✅ |

---

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  weorbis_motion_detector: ^1.0.0
````

Then, run `flutter pub get` to install the package.

-----

## Configuration

### Android

You need to add permissions and service declarations to your Android Manifest file.

**File**: `android/app/src/main/AndroidManifest.xml`

1.  Add the following permissions inside the `<manifest>` tag:

    ```xml
    <uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
    <uses-permission android:name="com.google.android.gms.permission.ACTIVITY_RECOGNITION" />

    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    ```

2.  Add the plugin's service and receiver declarations inside the `<application>` tag:

    ```xml
    <receiver android:name="com.weorbis.motion_detector.ActivityRecognizedBroadcastReceiver"/>
    <service
        android:name="com.weorbis.motion_detector.ActivityRecognizedService"
        android:permission="android.permission.BIND_JOB_SERVICE"
        android:exported="true"/>
    <service android:name="com.weorbis.motion_detector.ForegroundService" />
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

To use this plugin, you should also use the [permission\_handler](https://pub.dev/packages/permission_handler) package to request permissions on Android. On iOS, no explicit permission dialog is needed for Core Motion activity updates.

```dart
import 'package:weorbis_motion_detector/motion_detector_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

// ...

MotionDetector motionDetector = MotionDetector();
StreamSubscription<ActivityEvent>? streamSubscription;

void _startTracking() async {
  if (Platform.isAndroid) {
    if (await Permission.activityRecognition.request().isGranted) {
      // Permission granted, start listening
    }
  }
  
  streamSubscription = motionDetector.activityStream().listen((ActivityEvent event) {
    print('Activity Detected: ${event.type} (${event.confidence}%)');
    // Add event to a list and rebuild the UI
  });
}

// Don't forget to cancel the subscription when you're done!
@override
void dispose() {
  streamSubscription?.cancel();
  super.dispose();
}
```

### The `ActivityEvent` Model

The stream returns `ActivityEvent` objects with the following properties:

  * **`type`**: An `enum` (`ActivityType`) representing the detected activity.
  * **`confidence`**: An `int` (0-100) representing the confidence of the detection.
  * **`timeStamp`**: A `DateTime` object for when the event was created.

The possible `ActivityType` values are:

  * `IN_VEHICLE`
  * `ON_BICYCLE`
  * `ON_FOOT`
  * `RUNNING`
  * `STILL`
  * `TILTING`
  * `WALKING`
  * `UNKNOWN`
  * `INVALID` (used for parsing errors)

-----

## Contributing

Contributions are welcome\! Please feel free to submit a pull request or open an issue.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/weorbis/weorbis_motion_detector/blob/main/LICENSE) file for details.