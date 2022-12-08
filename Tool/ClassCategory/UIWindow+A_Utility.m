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

    for (UIWindow *C_window in C_windows.reverseObjectEnumerator) {
        if ([NSStringFromClass([C_window class]) isEqualToString:@"NotificationBannerSwift.NotificationBannerWindow"]
            || [NSStringFromClass([C_window class]) isEqualToString:@"UITextEffectsWindow"]
            || [NSStringFromClass([C_window class]) isEqualToString:@"UIRemoteKeyboardWindow"]) {
            continue;
        }
        BOOL windowIsVisible = !C_window.isHidden && C_window.alpha > 0.01;
        BOOL C_windowLevelSupported = C_window.windowLevel >= UIWindowLevelNormal;
        BOOL C_sameSize = (C_window.frame.size.height == C_size.height) && (C_window.frame.size.width == C_size.width);

        if (C_window.rootViewController && windowIsVisible && C_windowLevelSupported && C_sameSize) {
            return C_window;
        }
    }
    return C_avaiabelWindow;
}
@end
