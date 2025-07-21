#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PipManager : NSObject

+ (instancetype)sharedInstance;

- (void)setUpAudioSession;

- (BOOL) stopPIP;
- (BOOL) isInPIP;
- (BOOL) enablePIP: (NSString*) streamID;
- (void) updatePIPSource: (NSString*) streamID;
- (void) enableAutoPIP: (BOOL) isEnabled;
- (void) updatePIPAspectSize: (CGFloat) aspectWidth :(CGFloat) aspectHeight;

- (void) enableHardwareDecoder: (BOOL)isEnabled;
- (void) enableCustomVideoRender: (BOOL)isEnabled;

- (void) startPlayingStream:(NSString *)streamID;
- (void) updatePlayingStreamView:(NSString *)streamID videoView:(UIView *)videoView  viewMode:(NSNumber *)viewMode;
- (void) stopPlayingStream:(NSString *)streamID;

@end

NS_ASSUME_NONNULL_END
