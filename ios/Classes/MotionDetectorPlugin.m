#import "MotionDetectorPlugin.h"
#if __has_include(<weorbis_motion_detector/weorbis_motion_detector-Swift.h>)
#import <weorbis_motion_detector/weorbis_motion_detector-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "weorbis_motion_detector-Swift.h"
#endif

@implementation MotionDetectorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftMotionDetectorPlugin registerWithRegistrar:registrar];
}
@end
