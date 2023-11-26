#import "DeviceDetailsPlugin.h"
#if __has_include(<device_details_plugin/device_details_plugin-Swift.h>)
#import <device_details_plugin/device_details_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "device_details_plugin-Swift.h"
#endif

@implementation DeviceDetailsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDeviceDetailsPlugin registerWithRegistrar:registrar];
}
@end
