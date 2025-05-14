#import "PipManager.h"

#import <AVKit/AVKit.h>

#import "Masonry.h"
#import "KitRemoteView.h"

@import ZegoExpressEngine;

#define kFlutterLayerName   @"KitDisplayLayer"

static dispatch_once_t onceToken;
static id _instance;

API_AVAILABLE(ios(15.0))
@interface PipManager () <AVPictureInPictureControllerDelegate, ZegoCustomVideoRenderHandler>

@property (nonatomic, assign) BOOL isAutoStarted;
@property (nonatomic, assign) CGFloat aspectWidth;
@property (nonatomic, assign) CGFloat aspectHeight;

@property (nonatomic, strong) AVPictureInPictureController *pipController;
@property (nonatomic, strong) AVPictureInPictureVideoCallViewController *pipCallVC;

@property (nonatomic, strong) NSMutableDictionary<NSString *, UIView *> *flutterVideoViewDictionary;

@property (nonatomic, strong) KitRemoteView *pipVideoView;
@property (nonatomic, strong) AVSampleBufferDisplayLayer *pipLayer;
@property (nonatomic, strong) NSString *pipStreamID;

@end

@implementation PipManager

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isAutoStarted = YES;
        self.aspectWidth = 9;
        self.aspectHeight = 16;
        
        self.flutterVideoViewDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setUpAudioSession {
    @try {
        NSLog(@"[PIPManager] setUpAudioSession");
        
        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionModeMoviePlayback error:nil];
        [audioSession setActive:YES error:nil];
    } @catch (NSException *exception) {
        NSLog(@"[PIPManager] setUpAudioSession error:%@", exception);
    }
}

- (BOOL) startPIP : (NSString* ) streamID {
    NSLog(@"[PIPManager] startPIP, stream id:%@", streamID);
    
    [self updatePIPSource:streamID];
    
    if (@available(iOS 15.0, *)) {
        if ([AVPictureInPictureController isPictureInPictureSupported]) {
            [self updatePIPStreamID: streamID];
            
            if(nil != self.pipController) {
                if(! self.pipController.isPictureInPictureActive) {
                    NSLog(@"[PIPManager] startPIP run");
                    [self.pipController startPictureInPicture];
                }
            } else {
                NSLog(@"[PIPManager] startPIP, pip controller is nil");
            }
        }
    }
    
    return FALSE;
}

- (BOOL) stopPIP {
    NSLog(@"[PIPManager] stopPIP");
    
    if (@available(iOS 15.0, *)) {
        if ([AVPictureInPictureController isPictureInPictureSupported]) {
            if(nil != self.pipController) {
                if(self.pipController.isPictureInPictureActive) {
                    NSLog(@"[PIPManager] stopPIP run");
                    [self.pipController stopPictureInPicture];
                }
            }
        }
    }
    
    [self enableMultiTaskForSDK:FALSE];
    
    return FALSE;
}

- (BOOL) isInPIP {
    return [self.pipController isPictureInPictureActive];
}

- (void) updatePIPStreamID: (NSString*) streamID {
    NSLog(@"[PIPManager] updatePIPStreamID %@", streamID);
    
    self.pipStreamID = streamID;
}

- (void) updatePIPAspectSize: (CGFloat) aspectWidth :(CGFloat) aspectHeight {
    NSLog(@"[PIPManager] updatePIPAspectSize (%f, %f)", aspectWidth, aspectHeight);
    
    self.aspectWidth = aspectWidth;
    self.aspectHeight = aspectHeight;
}

- (void) updatePIPSource: (NSString*) streamID {
    NSLog(@"[PIPManager] updatePIPSource, stream id:%@", streamID);
    
    if(self.pipStreamID == streamID) {
        NSLog(@"[PIPManager] updatePIPSource, stream id is same");
        
        return;
    }
    [self updatePIPStreamID:streamID];
    
    if(nil == self.pipController) {
        NSLog(@"[PIPManager] updatePIPSource, pip controller is nil");
        
        return;
    }
    
    if (@available(iOS 17.4, *)) {
        UIView* flutterVideoView = [self.flutterVideoViewDictionary objectForKey:streamID];
        if(nil != flutterVideoView) {
            AVSampleBufferDisplayLayer* flutterDisplayLayer =[self getLayerOfView:flutterVideoView];
            if(! flutterDisplayLayer.isReadyForDisplay) {
                NSLog(@"[PIPManager] updatePIPSource, view is not ready for display, reject update");
                
                return;
            }
            
            AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithActiveVideoCallSourceView:flutterVideoView contentViewController:self.pipCallVC];
            self.pipController.contentSource = contentSource;
            
            NSLog(@"[PIPManager] updatePIPSource, update %@'s view to pip controller, view:%@, layer:%@", streamID, flutterVideoView, flutterDisplayLayer);
        } else {
            
            NSLog(@"[PIPManager] updatePIPSource, video view is nil");
        }
    }
}

- (void) enableAutoPIP: (BOOL) isEnabled {
    NSLog(@"[PIPManager] enableAutoPIP: %@", isEnabled ? @"YES" : @"NO");
    
    self.isAutoStarted = isEnabled;
}

- (BOOL) enablePIP: (NSString*) streamID  {
    NSLog(@"[PIPManager] enablePIP, stream id:%@", streamID);
    
    [self updatePIPStreamID: streamID];
    
    if (@available(iOS 15.0, *)) {
        if ([AVPictureInPictureController isPictureInPictureSupported]) {
            if(nil != self.pipController) {
                NSLog(@"[PIPManager] enablePIP, destory objects");
                
                self.pipLayer = NULL;
                self.pipVideoView = NULL;
                
                self.pipCallVC = NULL;
                self.pipController = NULL;
            }
            
            NSLog(@"[PIPManager] enablePIP, create objects");
            
            self.pipCallVC = [AVPictureInPictureVideoCallViewController new];
            self.pipCallVC.preferredContentSize = CGSizeMake(self.aspectWidth, self.aspectHeight);
            
            UIView* flutterVideoView = [self.flutterVideoViewDictionary objectForKey:streamID];
            AVPictureInPictureControllerContentSource *contentSource = [[AVPictureInPictureControllerContentSource alloc] initWithActiveVideoCallSourceView:flutterVideoView contentViewController:self.pipCallVC];
            
            self.pipController = [[AVPictureInPictureController alloc] initWithContentSource:contentSource];
            self.pipController.delegate = self;
            
            self.pipVideoView = [[KitRemoteView alloc] initWithFrame:CGRectZero];
            if(nil != self.pipCallVC) {
                NSLog(@"[PIPManager] enablePIP, add pip video view in pip call vc");
                [self.pipCallVC.view addSubview:self.pipVideoView];
            }
            
            self.pipVideoView.translatesAutoresizingMaskIntoConstraints = NO;
            [self.pipVideoView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.pipCallVC.view);
            }];
            
            self.pipLayer = [self createAVSampleBufferDisplayLayer];
            [self.pipVideoView addDisplayLayer:self.pipLayer];
            
            NSLog(@"[PIPManager] enablePIP, update auto started to %@", self.isAutoStarted ? @"YES" : @"NO");
            self.pipController.canStartPictureInPictureAutomaticallyFromInline = self.isAutoStarted;
        }
        
    }
    
    return YES;
}

- (void)enableHardwareDecoder: (BOOL) isEnabled {
    NSLog(@"[PIPManager] enableHardwareDecoder: %@", isEnabled ? @"YES" : @"NO");
    
    [[ZegoExpressEngine sharedEngine] enableHardwareDecoder:isEnabled];
}

- (void)enableCustomVideoRender: (BOOL) isEnabled {
    NSLog(@"[PIPManager] enableCustomVideoRender: %@", isEnabled ? @"YES" : @"NO");
    
    if(isEnabled) {
        // start custom rendering, deliver to different layers in rendering callback
        ZegoCustomVideoRenderConfig *renderConfig = [[ZegoCustomVideoRenderConfig alloc] init];
        renderConfig.bufferType = ZegoVideoBufferTypeCVPixelBuffer;
        renderConfig.frameFormatSeries = ZegoVideoFrameFormatSeriesRGB;
        renderConfig.enableEngineRender = YES;
        
        [[ZegoExpressEngine sharedEngine] enableCustomVideoRender:YES config:renderConfig];
        [[ZegoExpressEngine sharedEngine] setCustomVideoRenderHandler:self];
    } else {
        [[ZegoExpressEngine sharedEngine] setCustomVideoRenderHandler:nil];
        [[ZegoExpressEngine sharedEngine] enableCustomVideoRender:NO config:NULL];
    }
}

- (void)startPlayingStream:(NSString *)streamID videoView:(UIView *)videoView {
    NSLog(@"[PIPManager] startPlayingStream, stream id:%@, video view:%@", streamID, videoView);
    
    // add a layer for custom rendering to the video view, if not found, add one
    [self addFlutterLayerWithView:streamID :videoView];
    
    [[ZegoExpressEngine sharedEngine] startPlayingStream:streamID];
    
    if(self.pipController != nil && self.pipController.isPictureInPictureActive) {
        [self updatePIPStreamID: streamID];
    } else {
        [self enablePIP:streamID];
    }
    
    // Fix an unsolvable bug, occasionally layer rendering black screen
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(500 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//        [self performSelectorOnMainThread:@selector(rebuildFlutterLayer:) withObject:self.pipStreamID waitUntilDone:YES];
//    });
}

- (void)stopPlayingStream:(NSString *)streamID {
    NSLog(@"[PIPManager] stopPlayingStream, stream id:%@", streamID);
    
    UIView* flutterVideoView = [self.flutterVideoViewDictionary objectForKey:streamID];
    [flutterVideoView removeObserver:self forKeyPath:@"bounds"];
    [self.flutterVideoViewDictionary removeObjectForKey:streamID];
    
    [[ZegoExpressEngine sharedEngine] stopPlayingStream:streamID];
}

- (AVSampleBufferDisplayLayer *)createAVSampleBufferDisplayLayer
{
    NSLog(@"[PIPManager] createAVSampleBufferDisplayLayer");
    
    AVSampleBufferDisplayLayer *layer = [[AVSampleBufferDisplayLayer alloc] init];
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    layer.opaque = YES;
    
    return layer;
}

- (void)enableMultiTaskForSDK:(BOOL)enable
{
    NSLog(@"[PIPManager] enableMultiTaskForSDK: %@", enable ? @"YES" : @"NO");
    
    NSString *params = nil;
    if (enable){
        params = @"{\"method\":\"liveroom.video.enable_ios_multitask\",\"params\":{\"enable\":true}}";
        [[ZegoExpressEngine sharedEngine] callExperimentalAPI:params];
    } else {
        params = @"{\"method\":\"liveroom.video.enable_ios_multitask\",\"params\":{\"enable\":false}}";
        [[ZegoExpressEngine sharedEngine] callExperimentalAPI:params];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"bounds"]) {
        UIView *targetFlutterView = nil;
        for (UIView *view in self.flutterVideoViewDictionary.allValues) {
            if (view == object) {
                targetFlutterView = view;
                break;
            }
        }
        
        if(nil != targetFlutterView) {
            CGRect newBounds = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
            
            AVSampleBufferDisplayLayer* flutterDisplayLayer = [self getLayerOfView:targetFlutterView];
            if(nil != flutterDisplayLayer) {
                NSLog(@"[PIPManager] observeValueForKeyPath, sync display layer frame of flutter video view, %@", NSStringFromCGRect(newBounds));
                
                flutterDisplayLayer.frame = newBounds;
            } else {
                NSLog(@"[PIPManager] observeValueForKeyPath, not found display layer of flutter video view");
            }
        }
        
    }
}

#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PIPManager] pictureInPictureController willStart");
    [self enableMultiTaskForSDK:TRUE];
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PIPManager] pictureInPictureController didStart");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"[PIPManager] pictureInPictureController failedToStart, error: %@", error);
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PIPManager] pictureInPictureController willStop");
    
    [self enableMultiTaskForSDK:FALSE];
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController {
    NSLog(@"[PIPManager] pictureInPictureController didStop");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler {
    NSLog(@"[PIPManager] pictureInPictureController restoreUserInterface");
}

#pragma mark - ZegoCustomVideoRenderHandler

- (void)onRemoteVideoFrameCVPixelBuffer:(CVPixelBufferRef)buffer param:(ZegoVideoFrameParam *)param streamID:(NSString *)streamID
{
//    NSLog(@"pixel buffer video frame callback. format:%d, width:%f, height:%f", (int)param.format, param.size.width, param.size.height);

    
    CMSampleBufferRef sampleBuffer = [self createSampleBuffer:buffer];
    if (sampleBuffer) {
        UIView* flutterVideoView = [self.flutterVideoViewDictionary objectForKey:streamID];
        AVSampleBufferDisplayLayer *destLayer = [self getLayerOfViewInMainThread:flutterVideoView];
        if(self.pipController.pictureInPictureActive && [self.pipStreamID isEqualToString:streamID])  {
            destLayer = self.pipLayer;
        }
        
//        if (@available(iOS 17.4, *)) {
//            NSLog(@"[PIPManager] test onRemoteVideoFrameCVPixelBuffer streamID:%@, flutterVideoView:%@, dest layer:%@, in pip:(%@, %@), dest layer ready for display:%@, pip ready for display:%@",
//                  streamID, flutterVideoView, destLayer,
//                  self.pipController.pictureInPictureActive ? @"YES" : @"NO",
//                  [self.pipStreamID isEqualToString:streamID] ? @"YES" : @"NO",
//                  destLayer.isReadyForDisplay ? @"YES" : @"NO",
//                  self.pipController.contentSource.playerLayer.isReadyForDisplay ? @"YES" : @"NO");
//        } else {
//            // Fallback on earlier versions
//        }
        
        if(nil != destLayer) {
            [destLayer enqueueSampleBuffer:sampleBuffer];
            if (destLayer.status == AVQueuedSampleBufferRenderingStatusFailed) {
//                NSLog(@"[PIPManager] onRemoteVideoFrameCVPixelBuffer dest layer render failed, error:%ld", destLayer.error.code);
                
                if (-11847 == destLayer.error.code) {
                    if (destLayer == self.pipLayer) {
                        [self performSelectorOnMainThread:@selector(rebuildPIPLayer) withObject:NULL waitUntilDone:YES];
                    } else {
                        [self performSelectorOnMainThread:@selector(rebuildFlutterLayer:) withObject:streamID waitUntilDone:YES];
                    }
                }
            }
            
        }
        
        CFRelease(sampleBuffer);
    }
}

- (CMSampleBufferRef)createSampleBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (!pixelBuffer) {
        NSLog(@"[PIPManager] createSampleBuffer, pixelBuffer is null");
        return NULL;
    }
    
    // do not set specific time information
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    
    // get video information
    CMVideoFormatDescriptionRef videoInfo = NULL;
    
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    NSParameterAssert(result == 0 && videoInfo != NULL);
    
    CMSampleBufferRef sampleBuffer = NULL;
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    if (result != noErr) {
        NSLog(@"[PIPManager] createSampleBuffer, Failed to create sample buffer, error: %d", (int)result);
        return NULL;
    }
    NSParameterAssert(result == 0 && sampleBuffer != NULL);
    
    CFRelease(videoInfo);
    
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
    CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
    CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
    
    return sampleBuffer;
}

- (AVSampleBufferDisplayLayer*) getLayerOfView:(UIView *)videoView {
    if(nil == videoView) {
        return nil;
    }
    
    AVSampleBufferDisplayLayer* targetLayer = nil;
    for (CALayer *layer in videoView.layer.sublayers) {
        if ([layer.name isEqualToString:kFlutterLayerName]) {
            targetLayer = (AVSampleBufferDisplayLayer *)layer;
            if(!CGRectIsEmpty(videoView.bounds)) {
                targetLayer.frame = videoView.bounds;
            }
            break;
        }
    }
    
    return targetLayer;
}

- (AVSampleBufferDisplayLayer*) getLayerOfViewInMainThread:(UIView *)videoView {
    if(nil == videoView) {
        return nil;
    }
    
    __block AVSampleBufferDisplayLayer* targetLayer = nil;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        for (CALayer *layer in videoView.layer.sublayers) {
//            NSLog(@"[PIPManager] getLayerOfViewInMainThread, layer name:%@, layer:%@, view:%@", layer.name, layer, videoView);
            if ([layer.name isEqualToString:kFlutterLayerName]) {
                targetLayer = (AVSampleBufferDisplayLayer *)layer;
                if(!CGRectIsEmpty(videoView.bounds)) {
                    targetLayer.frame = videoView.bounds;
                }
                break;
            }
        }
    });
    
    return targetLayer;
}

- (void)addFlutterLayerWithView:(NSString *)streamID  :(UIView *)videoView  {
    NSLog(@"[PIPManager] addFlutterLayerWithView, video view:%@", videoView);
    
    UIView* flutterVideoView = [self.flutterVideoViewDictionary objectForKey:streamID];
    if (flutterVideoView != videoView) {
        NSLog(@"[PIPManager] addFlutterLayerWithView, update video view(%@) of stream(%@)", videoView, streamID);
        
        if(nil != flutterVideoView) {
            [flutterVideoView removeObserver:self forKeyPath:@"bounds"];
        }
        [self.flutterVideoViewDictionary setObject:videoView forKey:streamID];
    }
    
    AVSampleBufferDisplayLayer* displayLayer = [self getLayerOfView:videoView];
    if (nil == displayLayer) {
        displayLayer = [self createAVSampleBufferDisplayLayer];
        displayLayer.name = kFlutterLayerName;
        [videoView.layer addSublayer:displayLayer];
        displayLayer.frame = videoView.bounds;
        
        NSLog(@"[PIPManager] addFlutterLayerWithView, layer not found, add layer:%@ in videoView:%@", displayLayer, videoView);
    }
    
    [videoView addObserver:self forKeyPath:@"bounds" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)rebuildFlutterLayer:(NSString* )streamID {
    NSLog(@"[PIPManager] rebuildFlutterLayer, stream id:%@", streamID);
    
    @synchronized(self) {
        UIView* flutterVideoView = [self.flutterVideoViewDictionary objectForKey:streamID];
        if(nil != flutterVideoView) {
            AVSampleBufferDisplayLayer* displayLayer = [self getLayerOfView:flutterVideoView];
            if (nil != displayLayer) {
                NSLog(@"[PIPManager] rebuildFlutterLayer, remove %@ from super layer", displayLayer);
                [displayLayer removeFromSuperlayer];
            } else {
                NSLog(@"[PIPManager] rebuildFlutterLayer, layer is nil");
            }
        } else {
            NSLog(@"[PIPManager] rebuildFlutterLayer, video view is nil");
        }
        
        [self addFlutterLayerWithView:streamID :flutterVideoView];
    }
}

- (void)rebuildPIPLayer {
    NSLog(@"[PIPManager] rebuildPIPLayer");
    
    @synchronized(self) {
        if (self.pipLayer) {
            NSLog(@"[PIPManager] rebuildPIPLayer, remove %@ from super layer", self.pipLayer);
            
            [self.pipLayer removeFromSuperlayer];
            self.pipLayer = nil;
        }
        
        self.pipLayer = [self createAVSampleBufferDisplayLayer];
        [self.pipVideoView addDisplayLayer:self.pipLayer];
    }
}

@end
