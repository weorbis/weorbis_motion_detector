//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<permission_handler_apple/PermissionHandlerPlugin.h>)
#import <permission_handler_apple/PermissionHandlerPlugin.h>
#else
@import permission_handler_apple;
#endif

#if __has_include(<weorbis_motion_detector/MotionDetectorPlugin.h>)
#import <weorbis_motion_detector/MotionDetectorPlugin.h>
#else
@import weorbis_motion_detector;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [MotionDetectorPlugin registerWithRegistrar:[registry registrarForPlugin:@"MotionDetectorPlugin"]];
}

@end
