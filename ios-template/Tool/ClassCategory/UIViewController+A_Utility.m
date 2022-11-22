//
//  UIViewController+Utility.m
//  GC_OC
//
//  Created by  Quan He on 2022/4/8.
//

#import "UIViewController+A_Utility.h"
#import "UIWindow+A_Utility.h"

@implementation UIViewController (A_Utility)
+ (UIViewController *)findBestViewController:(UIViewController *)C_vc
{
    if (C_vc.presentedViewController) {
        // Return presented view controller
        return [UIViewController findBestViewController:C_vc.presentedViewController];
        
    } else if ([C_vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController *svc = (UISplitViewController *)C_vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.viewControllers.lastObject];
        else
            return C_vc;
        
    } else if ([C_vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *)C_vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.topViewController];
        else
            return C_vc;
        
    } else if ([C_vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *)C_vc;
        if (svc.viewControllers.count > 0)
            return [UIViewController findBestViewController:svc.selectedViewController];
        else
            return C_vc;
    } else {
        return C_vc;
    }
}

+ (UIViewController *)B_currentViewController
{
    UIWindow *C_keyWindow = [UIWindow B_availableWindow];
    NSAssert(C_keyWindow != nil, @"KeyWindow is nil");

    UIViewController *viewController = [C_keyWindow rootViewController];
    return [UIViewController findBestViewController:viewController];
}

@end
