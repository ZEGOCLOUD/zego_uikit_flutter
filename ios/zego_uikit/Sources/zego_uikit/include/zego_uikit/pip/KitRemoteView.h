#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KitRemoteView : UIView

@property(nonatomic, strong) AVSampleBufferDisplayLayer *displayLayer;

- (void)addDisplayLayer:(AVSampleBufferDisplayLayer *)layer;

@end

NS_ASSUME_NONNULL_END
