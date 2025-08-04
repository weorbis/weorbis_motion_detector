part of weorbis_motion_detector;

/// The different types of motion that can be detected.
///
/// These types are aligned with the Android `DetectedActivity` constants,
/// and iOS `CMMotionActivity` types are mapped to these for consistency.
enum MotionType {
  /// The device is in a vehicle, such as a car.
  IN_VEHICLE,

  /// The device is on a bicycle.
  ON_BICYCLE,

  /// The device is on a user who is on foot, either walking or running.
  ON_FOOT,

  /// The device is on a user who is running.
  RUNNING,

  /// The device is still (not moving).
  STILL,

  /// The device's tilt is changing.
  TILTING,

  /// An unknown activity was detected.
  UNKNOWN,

  /// The device is on a user who is walking.
  WALKING,

  /// Used for parsing errors or invalid data.
  INVALID
}

/// A map to convert native activity type strings to the [MotionType] enum.
Map<String, MotionType> _motionTypeMap = {
  // Android
  'IN_VEHICLE': MotionType.IN_VEHICLE,
  'ON_BICYCLE': MotionType.ON_BICYCLE,
  'ON_FOOT': MotionType.ON_FOOT,
  'RUNNING': MotionType.RUNNING,
  'STILL': MotionType.STILL,
  'TILTING': MotionType.TILTING,
  'UNKNOWN': MotionType.UNKNOWN,
  'WALKING': MotionType.WALKING,

  // iOS
  'automotive': MotionType.IN_VEHICLE,
  'cycling': MotionType.ON_BICYCLE,
  'running': MotionType.RUNNING,
  'stationary': MotionType.STILL,
  'unknown': MotionType.UNKNOWN,
  'walking': MotionType.WALKING,
};

/// Represents a single motion activity event detected by the device.
class MotionEvent {
  /// The type of motion detected.
  final MotionType type;

  /// The confidence of the detection, from 0 to 100 percent.
  final int confidence;

  /// The timestamp when the event was detected.
  final DateTime timeStamp;

  /// The type of motion as a human-readable string.
  String get typeString => type.toString().split('.').last;

  MotionEvent(this.type, this.confidence) : timeStamp = DateTime.now();

  /// Creates a [MotionEvent] with an 'UNKNOWN' type and 100% confidence.
  factory MotionEvent.unknown() => MotionEvent(MotionType.UNKNOWN, 100);

  /// Creates a [MotionEvent] from a comma-separated string `type,confidence`.
  factory MotionEvent.fromString(String data) {
    final List<String> tokens = data.split(",");
    if (tokens.length < 2) return MotionEvent.unknown();

    final MotionType type = _motionTypeMap[tokens.first] ?? MotionType.UNKNOWN;
    final int? conf = int.tryParse(tokens.last);

    return MotionEvent(type, conf ?? 0);
  }

  @override
  String toString() => 'Motion - type: $typeString, confidence: $confidence%';
}
