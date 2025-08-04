import Flutter
import UIKit
import CoreMotion

/// The main plugin class for the iOS implementation.
public class SwiftMotionDetectorPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let handler = ActivityStreamHandler()
    let channel = FlutterEventChannel(name: "weorbis_motion_detector", binaryMessenger: registrar.messenger())
    channel.setStreamHandler(handler)
  }
}

/// A stream handler that manages motion activity updates from CoreMotion.
public class ActivityStreamHandler: NSObject, FlutterStreamHandler {

  private let activityManager = CMMotionActivityManager()

  /// Called when Flutter begins listening to the event stream.
  public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
    guard CMMotionActivityManager.isActivityAvailable() else {
        return FlutterError(code: "UNAVAILABLE", message: "Motion activity is not available on this device.", details: nil)
    }
    
    activityManager.startActivityUpdates(to: OperationQueue.main) { (activity) in
        if let activity = activity {
            let type = self.getMotionType(from: activity)
            let confidence = self.getConfidence(from: activity.confidence)
            let data = "\(type),\(confidence)"
            eventSink(data)
        }
    }
    return nil
  }

  /// Called when Flutter cancels the stream subscription.
  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    activityManager.stopActivityUpdates()
    return nil
  }

  /// Converts a CMMotionActivity object into a standardized string type.
  private func getMotionType(from activity: CMMotionActivity) -> String {
    switch true {
    case activity.stationary:
        return "STILL"
    case activity.walking:
        return "WALKING"
    case activity.running:
        return "RUNNING"
    case activity.automotive:
        return "IN_VEHICLE"
    case activity.cycling:
        return "ON_BICYCLE"
    default:
        return "UNKNOWN"
    }
  }

  /// Converts a CMMotionActivityConfidence enum into an integer percentage.
  private func getConfidence(from confidence: CMMotionActivityConfidence) -> Int {
    switch confidence {
    case .low:
        return 10
    case .medium:
        return 50
    case .high:
        return 100
    default:
        return 0
    }
  }
}