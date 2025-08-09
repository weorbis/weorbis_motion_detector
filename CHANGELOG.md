# 1.1.1

* **FEAT**: `getCurrentActivity()` no longer starts the Android foreground service and now includes a configurable timeout.
* **FIX**: Replaced broken example widget test with a working app bar title check.
* **CHORE**: Removed unused `permission_handler` dev dependency from the example project.
* **FEAT**: Android plugin manifest now declares required receiver, services, and permissions — no manual manifest edits needed in consuming apps.
* **CHORE**: Cleaned up example app manifest to avoid duplicate declarations.
* **DOCS**: Updated README to reflect the recent changes.
* **CHORE**: Added `.flutter-plugins-dependencies` to `.gitignore`.

# 1.1.0

* **CRITICAL FIX**: Corrected bug on Android that used a non-existent `MotionDetector` API. The plugin now correctly uses `ActivityRecognitionClient`.
* **CRITICAL FIX**: Resolved a `ClassCastException` crash on Android when starting the foreground service.
* **FEAT**: Added a `requestPermission()` helper method to simplify permission requests.
* **FEAT**: Added a `getCurrentActivity()` method to get a single, on-demand motion update.
* **FEAT**: Added a configurable update interval for Android via the `androidUpdateIntervalMillis` parameter.
* **FEAT**: The Android foreground service notification is now fully configurable (title, text, icon).
* **CHORE**: Reorganized file structure by moving data models into a `lib/models` directory.
* **CHORE**: Updated iOS `.podspec` with accurate metadata.
* **DEPS**: Added `permission_handler` as a direct dependency.
* **DOCS**: Major documentation update to reflect all new features and fixes.

# 1.0.0

* **Initial Release**
* Forked from `activity_recognition_flutter`.
* Complete rebranding to `weorbis_motion_detector`.
* Modernized Android integration.
* Modernized iOS integration.
* Updated dependencies.
* Cleaned up and fully rebranded the example application.
