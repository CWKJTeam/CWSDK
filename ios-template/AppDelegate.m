#import "AppDelegate.h"
#import "A_BViewController.h"
#import "A_UpdateController.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>
#import "Firebase.h"
#import <LineSDK/LineSDK.h>
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    NSString *str = [NSString B_setSafeString:[[[url absoluteString] componentsSeparatedByString:@"//"] lastObject]];
    _arguments = str;
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否删除？" message:str delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    [alertView show];
    
    
    return [[LineSDKLogin sharedInstance] handleOpenURL:url];
}

- (void)requestIDFA {
    if (@available(iOS 14, *)) {
            // iOS14及以上版本需要先请求权限
            [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
                // 获取到权限后，依然使用老方法获取idfa
                if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                    NSString *idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
                    NSLog(@"idfa-->>%@",idfa);
//                    [[AppsFlyerLib shared] start];
                } else {
                         NSLog(@"请在设置-隐私-跟踪中允许App请求跟踪");
                }
            }];
        } else {
            // iOS14以下版本依然使用老方法
            // 判断在设置-隐私里用户是否打开了广告跟踪
            if ([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
                NSString *idfa = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
                NSLog(@"idfa-->>%@",idfa);

//                [[AppsFlyerLib shared] start];
            } else {
                if([[NSUserDefaults standardUserDefaults] integerForKey:@"appstartcount"] == 0){
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Allow apps to track your activity on other company APPS and websites" message:@"Apps collect relevant data for advertising optimization and analytics purposes" delegate:@"" cancelButtonTitle:@"required not to track" otherButtonTitles:@"allow", nil];
                    [alert show];
                    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"appstartcount"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
        }
}

//- (BOOL)application:(UIApplication *)application
//    openURL:(NSURL *)url
//    sourceApplication:(NSString *)sourceApplication
//    annotation:(id)annotation {
//
//    return [[ZDKApplicationDelegate sharedInstance]
//    application:application
//    openURL:url sourceApplication:sourceApplication annotation:annotation];
//}



-(void)gameStart{
    _isverScreen = YES;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    A_BViewController *viewcontroller = [[A_BViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = viewcontroller;
    [self.window makeKeyAndVisible];
}

//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options
//{
//
//}

- (void)onConversionDataSuccess:(NSDictionary *)conversionInfo{
    NSLog(@"conversionInfo~~>>%@",conversionInfo);
}

- (void)onConversionDataFail:(NSError *)error{
    
}

- (void)sendLaunch:(UIApplication *)application {
    
    [[AppsFlyerLib shared] startWithCompletionHandler:^(NSDictionary<NSString *,id> *dictionary, NSError *error) {
            if (error) {
                NSLog(@"error~~~~>~%@", error);
                return;
            }
            if (dictionary) {
                NSLog(@"dictionary~~~>>~%@", dictionary);
                return;
            }
        }];
    
//    [[AppsFlyerLib shared] start];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[NSUserDefaults standardUserDefaults] setValue:[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]] forKey:@"game_AppReport_Launching_dadian"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   
    [[AppsFlyerLib shared] setAppsFlyerDevKey:@"aJ3XzPxyxkw9SkSR57ugvU"];
    [[AppsFlyerLib shared] setAppleAppID:@"6444476945"];
    [AppsFlyerLib shared].isDebug = true;
    [AppsFlyerLib shared].delegate = self;
    
    [[AppsFlyerLib shared] waitForATTUserAuthorizationWithTimeoutInterval:120.0];
    [[NSNotificationCenter defaultCenter] addObserver:self
         selector:@selector(sendLaunch:)
         name:UIApplicationDidBecomeActiveNotification
         object:nil];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            center.delegate = self;
            [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            }];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    
    [FIRApp configure];

    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"isisisfirst"] == 0) {
        [self gameStart];
        return YES;
    }
    
    _isverScreen = NO;
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationMaskLandscape];
    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    
    
    NSDate *startD = [[NSUserDefaults standardUserDefaults]valueForKey:@"fbinfo_date"];
    if(!startD){

        NSDate *endD = [NSDate date];
        NSTimeInterval start = [startD timeIntervalSince1970]*1;
        NSTimeInterval end = [endD timeIntervalSince1970]*1;
        NSTimeInterval value = end - start;
        NSString*days = [NSString stringWithFormat:@"%d",(int)value / (24*3600)];
        NSString*hours = [NSString stringWithFormat:@"%d",(int)(value-days.integerValue*24*3600) /  3600];
        NSString*minutes = [NSString stringWithFormat:@"%d",(int)value /60%60];
        NSString*format_time = [NSString stringWithFormat:@"距离截止：%@天%@时%@分",days,hours,minutes];
        NSLog(@"~~~~~~>>%@",format_time);
        if ([hours intValue]>0||[days intValue]>0) {
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"fbinfo"];
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"fbinfo_date"];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"game_AppReport_Launching"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    A_UpdateController *viewcontroller = [[A_UpdateController alloc] initWithNibName:nil bundle:nil];
        self.window.rootViewController = viewcontroller;
    [self.window makeKeyAndVisible];
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {

    if(!_isverScreen) {
        // 横屏
        return UIInterfaceOrientationMaskLandscape;
    } else {
        // 竖屏
        return UIInterfaceOrientationMaskPortrait;
    }
}

//如果iOS版本是9.0及以上的，会在下面方法接受到在地址栏输入的字符串
//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
//{
//    NSString *str = [NSString setSafeString:[[[url absoluteString] componentsSeparatedByString:@"//"] lastObject]];
//    _arguments = str;
//    return YES;
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
//    [_native pause];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
//    [_native resume];
}
        
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [[AppsFlyerLib shared] start];
    [self requestIDFA];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

@end
