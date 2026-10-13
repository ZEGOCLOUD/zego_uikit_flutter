#import "AVAudioSession+Zego.h"
#import <objc/runtime.h>

@implementation AVAudioSession (Zego)

+ (void)forceLoad {
    // Intentionally empty. Just for linker to see this symbol.
    // 故意留空。仅为了让链接器看到这个符号。
}

/**
 * Load method is called when the class is loaded into memory.
 * 当类加载到内存时调用 load 方法，这是执行 Method Swizzling 的最佳时机。
 */
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Swizzle setCategory:error:
        // 交换 setCategory:error: 方法
        [self zego_uikit_swizzleMethod:@selector(setCategory:error:)
                            withMethod:@selector(zego_uikit_setCategory:error:)];
        
        // Swizzle setCategory:withOptions:error:
        // 交换 setCategory:withOptions:error: 方法
        [self zego_uikit_swizzleMethod:@selector(setCategory:withOptions:error:)
                            withMethod:@selector(zego_uikit_setCategory:withOptions:error:)];
    });
}

/**
 * Helper method to swizzle instance methods.
 * 用于交换实例方法的辅助方法。
 *
 * @param originalSelector Original method selector / 原始方法选择器
 * @param swizzledSelector Swizzled method selector / 交换后的方法选择器
 */
+ (void)zego_uikit_swizzleMethod:(SEL)originalSelector withMethod:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(self, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(self,
                                        originalSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(self,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

/**
 * Swizzled implementation of setCategory:error:
 * setCategory:error: 的交换实现
 */
- (BOOL)zego_uikit_setCategory:(AVAudioSessionCategory)category error:(NSError * _Nullable __autoreleasing *)outError {
    // Force correction: If setting Playback without options, upgrade to include MixWithOthers
    // 强制修正：如果是 Playback 且没有 MixWithOthers，自动升级为带 MixWithOthers 的方法
    if ([category isEqualToString:AVAudioSessionCategoryPlayback]) {
        NSLog(@"[ZegoUIKit] Intercepted Playback setting without options, forcing MixWithOthers.");
        return [self zego_uikit_setCategory:category withOptions:AVAudioSessionCategoryOptionMixWithOthers error:outError];
    }
    
    // Call original implementation (which is now swizzled to this method name)
    // 调用原始实现（此时已被交换为此方法名）
    return [self zego_uikit_setCategory:category error:outError];
}

/**
 * Swizzled implementation of setCategory:withOptions:error:
 * setCategory:withOptions:error: 的交换实现
 */
- (BOOL)zego_uikit_setCategory:(AVAudioSessionCategory)category withOptions:(AVAudioSessionCategoryOptions)options error:(NSError * _Nullable __autoreleasing *)outError {
    AVAudioSessionCategoryOptions finalOptions = options;
    
    // Force correction: If Playback is missing MixWithOthers, add it
    // 强制修正：如果是 Playback 且缺少 MixWithOthers 选项，强制加上
    if ([category isEqualToString:AVAudioSessionCategoryPlayback]) {
        if (!(finalOptions & AVAudioSessionCategoryOptionMixWithOthers)) {
            NSLog(@"[ZegoUIKit] Intercepted Playback setting (Options: %lu), forcing MixWithOthers.", (unsigned long)options);
            finalOptions |= AVAudioSessionCategoryOptionMixWithOthers;
        }
    }

    // Call original implementation
    // 调用原始实现
    return [self zego_uikit_setCategory:category withOptions:finalOptions error:outError];
}

/**
 * Swizzled implementation of setCategory:mode:options:error:
 * setCategory:mode:options:error: 的交换实现
 */
- (BOOL)zego_uikit_setCategory:(AVAudioSessionCategory)category mode:(AVAudioSessionMode)mode options:(AVAudioSessionCategoryOptions)options error:(NSError * _Nullable __autoreleasing *)outError {
    AVAudioSessionCategoryOptions finalOptions = options;
    
    // Force correction: If Playback is missing MixWithOthers, add it
    // 强制修正：如果是 Playback 且缺少 MixWithOthers 选项，强制加上
    if ([category isEqualToString:AVAudioSessionCategoryPlayback]) {
        if (!(finalOptions & AVAudioSessionCategoryOptionMixWithOthers)) {
            NSLog(@"[ZegoUIKit] Intercepted Playback setting (Mode: %@, Options: %lu), forcing MixWithOthers.", mode, (unsigned long)options);
            finalOptions |= AVAudioSessionCategoryOptionMixWithOthers;
        }
    }

    // Call original implementation
    // 调用原始实现
    return [self zego_uikit_setCategory:category mode:mode options:finalOptions error:outError];
}

@end
