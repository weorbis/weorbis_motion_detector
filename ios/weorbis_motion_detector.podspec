#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint weorbis_motion_detector.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'weorbis_motion_detector'
  s.version          = '1.1.2'
  s.summary          = 'A Flutter plugin for Android and iOS that provides access to the device motion activity.'
  s.description      = <<-DESC
    A Flutter plugin for Android and iOS that provides access to the device's motion activity. It streams activity updates like `STILL`, `WALKING`, `RUNNING`, `IN_VEHICLE`, etc., detected by the phone's hardware.
                       DESC
  s.homepage         = 'https://github.com/weorbis/weorbis_motion_detector'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'WeOrbis' => 'contact@weorbis.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'
  s.framework = 'CoreMotion'

  
  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.9'
end
