#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * Category to intercept and correct AVAudioSession configuration for ZegoUIKit.
 * 用于拦截和修正 ZegoUIKit 的 AVAudioSession 配置的分类。
 */
@interface AVAudioSession (Zego)

/**
 * Force load the category to prevent linker stripping.
 * 强制加载分类，防止被链接器优化丢弃。
 */
+ (void)forceLoad;

@end

NS_ASSUME_NONNULL_END
