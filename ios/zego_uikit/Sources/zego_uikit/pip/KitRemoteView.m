#import "pip/KitRemoteView.h"

@implementation KitRemoteView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _displayLayer = NULL;
    }
    return self;
}

- (void)addDisplayLayer:(AVSampleBufferDisplayLayer *)layer {
    [self.layer addSublayer:layer];
    self.displayLayer = layer;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.displayLayer.frame = self.bounds;
}

@end
