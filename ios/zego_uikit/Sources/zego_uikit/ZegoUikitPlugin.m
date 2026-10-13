#import "ZegoUikitPlugin.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "AVAudioSession+Zego.h" // 引入拦截器头文件

/// flutter express
#import <zego_express_engine_for_uikit/ZegoCustomVideoProcessManager.h>
#import <zego_express_engine_for_uikit/ZegoCustomVideoCaptureManager.h>
#if SWIFT_PACKAGE
#import <zego_express_engine_for_uikit/internal/ZegoExpressEngineMethodHandler.h>
#import <zego_express_engine_for_uikit/internal/ZegoPlatformViewFactory.h>
#import <zego_express_engine_for_uikit/internal/ZegoPlatformView.h>
#else
#import <zego_express_engine_for_uikit/ZegoExpressEngineMethodHandler.h>
#import <zego_express_engine_for_uikit/ZegoPlatformViewFactory.h>
#import <zego_express_engine_for_uikit/ZegoPlatformView.h>
#endif
#import <ZegoUIKitReport/ZegoUIKitReport.h>

#import "pip/PipManager.h"

@implementation ZegoUikitPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [AVAudioSession forceLoad]; // 强制加载拦截器，确保 Swizzling 生效

    // Do not configure or activate AVAudioSession during plugin registration.
    // CallKit must own activation for incoming calls; activating Playback here
    // races CallKit and can make the audio capture AudioUnit fail to initialize.
    NSLog(@"[UIKit Plugin] audio session activation deferred to the active feature");

    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"zego_uikit_plugin"
                                     binaryMessenger:[registrar messenger]];
    ZegoUikitPlugin* instance = [[ZegoUikitPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    //    NSLog(@"[UIKit Plugin] handleMethodCall, method: %@", call.method);
    
    if ([@"isLockScreen" isEqualToString:call.method]) {
        result(@([UIScreen mainScreen].brightness == 0.0));
    } else if ([@"isInPIP" isEqualToString:call.method]) {
        BOOL callResult = [[PipManager sharedInstance] isInPIP];
        
        result(@(callResult));
    } else if ([@"minimizeApp" isEqualToString:call.method]) {
        [self minimizeApp];
        
        result(nil);
    } else if ([@"enableHardwareDecoder" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        
        NSNumber *enabledValue = arguments[@"enabled"];
        BOOL isEnabled = [enabledValue boolValue];
        
        NSLog(@"[UIKit Plugin] enableHardwareDecoder, isEnabled: %@", isEnabled ? @"YES" : @"NO");
        [[PipManager sharedInstance] enableHardwareDecoder:isEnabled];
        
        result(nil);
    } else if ([@"enableCustomVideoRender" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        
        NSNumber *enabledValue = arguments[@"enabled"];
        BOOL isEnabled = [enabledValue boolValue];
        
        NSLog(@"[UIKit Plugin] enableCustomVideoRender, isEnabled: %@", isEnabled ? @"YES" : @"NO");
        [[PipManager sharedInstance] enableCustomVideoRender:isEnabled];
        
        result(nil);
    } else if ([@"enableAutoPIP" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        
        NSNumber *enabledValue = arguments[@"enabled"];
        BOOL isEnabled = [enabledValue boolValue];
        
        NSNumber* aspectWidth = arguments[@"aspect_width"];
        NSNumber* aspectHeight = arguments[@"aspect_height"];
        CGFloat cgFloatAspectWidth = [aspectWidth floatValue];
        CGFloat cgFloatAspectHeight = [aspectHeight floatValue];
        
        NSLog(@"[UIKit Plugin] enableAutoPIP, isEnabled: %@", isEnabled ? @"YES" : @"NO");
        
        [[PipManager sharedInstance] updatePIPAspectSize:cgFloatAspectWidth :cgFloatAspectHeight];

        [[PipManager sharedInstance] enableAutoPIP:isEnabled];
        
        result(nil);
    } else if ([@"enablePIP" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSString *streamID = arguments[@"stream_id"];
        
        NSNumber* aspectWidth = arguments[@"aspect_width"];
        NSNumber* aspectHeight = arguments[@"aspect_height"];
        CGFloat cgFloatAspectWidth = [aspectWidth floatValue];
        CGFloat cgFloatAspectHeight = [aspectHeight floatValue];
        
        NSLog(@"[UIKit Plugin] enablePIP, streamID: %@", streamID);
        
        [[PipManager sharedInstance] updatePIPAspectSize:cgFloatAspectWidth :cgFloatAspectHeight];
        
        [[PipManager sharedInstance] enablePIP:streamID];
        
        result(nil);
    } else if ([@"updatePIPSource" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSString *streamID = arguments[@"stream_id"];
        
        NSLog(@"[UIKit Plugin] updatePIPSource, streamID: %@", streamID);
        
        [[PipManager sharedInstance] updatePIPSource:streamID];
        
        result(nil);
    } else if ([@"stopPIP" isEqualToString:call.method]) {
        NSLog(@"[UIKit Plugin] stopPIP");
        
        BOOL callResult = [[PipManager sharedInstance] stopPIP];
        
        result(@(callResult));
    } else if ([@"startPlayingStreamInPIP" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;

        NSString *streamID = arguments[@"stream_id"];
        NSNumber *resourceMode = arguments[@"resourceMode"];
        NSString *roomID = arguments[@"roomID"];
        NSDictionary *cdnConfig = arguments[@"cdnConfig"];
        NSNumber *videoCodecID = arguments[@"videoCodecID"];

        NSLog(@"[UIKit Plugin] startPlayingStreamInPIP, streamID: %@, resourceMode: %@, roomID: %@, cdnConfig: %@, videoCodecID: %@",
              streamID, resourceMode, roomID, cdnConfig, videoCodecID);
        NSLog(@"[UIKit Plugin][PIPTrace] received startPlayingStreamInPIP, "
              "appState=%ld, pipActive=%d",
              (long)[UIApplication sharedApplication].applicationState,
              [[PipManager sharedInstance] isInPIP]);
        [self startPlayingStreamInPIP:streamID
                         resourceMode:resourceMode
                               roomID:roomID
                            cdnConfig:cdnConfig
                         videoCodecID:videoCodecID];

        result(nil);
    } else if ([@"updatePlayingStreamViewInPIP" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        
        NSNumber *viewID = arguments[@"view_id"];
        NSString *streamID = arguments[@"stream_id"];
        NSNumber *viewMode = arguments[@"view_mode"];
        
        NSLog(@"[UIKit Plugin] updatePlayingStreamViewInPIP, viewID: %@, streamID: %@, viewMode: %@",
              viewID, streamID, viewMode);
        [self updatePlayingStreamViewInPIP:viewID streamID:streamID viewMode:viewMode];
        
        result(nil);
    } else if ([@"stopPlayingStreamInPIP" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSString *streamID = arguments[@"stream_id"];
        
        NSLog(@"[UIKit Plugin] stopPlayingStreamInPIP, streamID: %@", streamID);
        NSLog(@"[UIKit Plugin][PIPTrace] received stopPlayingStreamInPIP, "
              "appState=%ld, pipActive=%d",
              (long)[UIApplication sharedApplication].applicationState,
              [[PipManager sharedInstance] isInPIP]);
        [self stopPlayingStreamInPIP:streamID];
        
        result(nil);
    } else if ([@"reporterCreate" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        
        NSNumber *appID = arguments[@"app_id"];
        unsigned int appIDIntValue = [appID unsignedIntValue];

        NSString *signOrToken = arguments[@"sign_token"];
        NSDictionary *commonParams = arguments[@"params"];

        [[ReportUtil sharedInstance] createWithAppID:appIDIntValue signOrToken:signOrToken commonParams:commonParams];

        result(nil);
    } else if ([@"reporterDestroy" isEqualToString:call.method]) {
        [[ReportUtil sharedInstance] destroy];

        result(nil);
    } else if ([@"reporterUpdateToken" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSString *token = arguments[@"token"];

        [[ReportUtil sharedInstance] updateToken:token];
        result(nil);
    } else if ([@"reporterUpdateCommonParams" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSDictionary *commonParams = arguments[@"params"];
        
        [[ReportUtil sharedInstance] updateCommonParams:commonParams];
        
        result(nil);
    } else if ([@"reporterEvent" isEqualToString:call.method]) {
        NSDictionary *arguments = call.arguments;
        NSString *event = arguments[@"event"];
        NSDictionary *paramsMap = arguments[@"params"];

        [[ReportUtil sharedInstance] reportEvent:event paramsDict:paramsMap];
        
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)minimizeApp {
    NSLog(@"[UIKit Plugin] minimizeApp");
    
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
}

- (void)startPlayingStreamInPIP:(NSString *)streamID
                   resourceMode:(nullable NSNumber *)resourceMode
                         roomID:(nullable NSString *)roomID
                      cdnConfig:(nullable NSDictionary *)cdnConfig
                   videoCodecID:(nullable NSNumber *)videoCodecID {
    NSLog(@"[UIKit Plugin][PIPTrace] schedule native startPlayingStream, "
          "streamID=%@, appState=%ld",
          streamID,
          (long)[UIApplication sharedApplication].applicationState);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[UIKit Plugin][PIPTrace] execute native startPlayingStream, "
              "streamID=%@, appState=%ld",
              streamID,
              (long)[UIApplication sharedApplication].applicationState);
        [[PipManager sharedInstance] startPlayingStream:streamID
                                           resourceMode:resourceMode
                                                 roomID:roomID
                                              cdnConfig:cdnConfig
                                           videoCodecID:videoCodecID];
    });
}

- (void)updatePlayingStreamViewInPIP:(NSNumber *)viewID streamID:(NSString *)streamID viewMode:(NSNumber *)viewMode  {
    NSLog(@"[UIKit Plugin][PIPTrace] resolve native view, viewID=%@, "
          "streamID=%@, viewMode=%@, pipActive=%d",
          viewID,
          streamID,
          viewMode,
          [[PipManager sharedInstance] isInPIP]);
    ZegoPlatformView *platformView = [[ZegoPlatformViewFactory sharedInstance] getPlatformView:viewID];
    if(platformView == nil) {
        NSLog(@"[UIKit Plugin][PIPTrace] platformView lookup failed, "
              "viewID=%@, streamID=%@", viewID, streamID);
        
        return;
    }

    UIView *nativeView = platformView.view;
    NSLog(@"[UIKit Plugin][PIPTrace] resolved native view, viewID=%@, "
          "streamID=%@, view=%p, class=%@, frame=%@, bounds=%@, "
          "window=%p, superview=%p, hidden=%d, alpha=%.3f",
          viewID,
          streamID,
          nativeView,
          nativeView ? NSStringFromClass(nativeView.class) : @"(nil)",
          NSStringFromCGRect(nativeView.frame),
          NSStringFromCGRect(nativeView.bounds),
          nativeView.window,
          nativeView.superview,
          nativeView.hidden,
          nativeView.alpha);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[UIKit Plugin][PIPTrace] execute native updatePlayingStreamView, "
              "viewID=%@, streamID=%@, view=%p, pipActive=%d",
              viewID,
              streamID,
              nativeView,
              [[PipManager sharedInstance] isInPIP]);
        [[PipManager sharedInstance] updatePlayingStreamView:streamID videoView:nativeView viewMode:viewMode];
    });
}

- (void)stopPlayingStreamInPIP:(NSString *)streamID  {
    NSLog(@"[UIKit Plugin][PIPTrace] schedule native stopPlayingStream, "
          "streamID=%@, appState=%ld",
          streamID,
          (long)[UIApplication sharedApplication].applicationState);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"[UIKit Plugin][PIPTrace] execute native stopPlayingStream, "
              "streamID=%@, appState=%ld",
              streamID,
              (long)[UIApplication sharedApplication].applicationState);
        [[PipManager sharedInstance] stopPlayingStream:streamID];
    });
}

@end
