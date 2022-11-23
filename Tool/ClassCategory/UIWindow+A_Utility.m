//
//  UIWindow+Utility.m
//  GC_OC
//
//  Created by  Quan He on 2022/4/8.
//

#import "UIWindow+A_Utility.h"

@implementation UIWindow (A_Utility)

+ (nullable UIWindow *)B_availableWindow {
    return [self availableWindowWithSize:UIScreen.mainScreen.bounds.size];
}

+ (nullable UIWindow *)availableWindowWithSize:(CGSize)C_size{
    NSAssert(C_size.width != 0, @"width is zero");
    NSAssert(C_size.height != 0, @"height is zero");

    NSArray <UIWindow *> *C_windows = [UIApplication sharedApplication].windows;
    UIWindow *C_avaiabelWindow;

    for (UIWindow *window in C_windows.reverseObjectEnumerator) {
        if ([NSStringFromClass([window class]) isEqualToString:@"NotificationBannerSwift.NotificationBannerWindow"]
            || [NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]
            || [NSStringFromClass([window class]) isEqualToString:@"UIRemoteKeyboardWindow"]) {
            continue;
        }
        BOOL windowIsVisible = !window.isHidden && window.alpha > 0.01;
        BOOL C_windowLevelSupported = window.windowLevel >= UIWindowLevelNormal;
        BOOL C_sameSize = (window.frame.size.height == C_size.height) && (window.frame.size.width == C_size.width);

        if (window.rootViewController && windowIsVisible && C_windowLevelSupported && C_sameSize) {
            return window;
        }
    }
    return C_avaiabelWindow;
}
@end
