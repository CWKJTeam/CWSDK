//
//  UpBassController.m
//  vpower(i_1)
//
//  Created by 叶建辉 on 2021/12/10.
//  Copyright © 2021 egret. All rights reserved.
//

#import "A_UpBassController.h"

@interface A_UpBassController ()

@end

@implementation A_UpBassController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(B_appBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(B_appEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
  
    
//    [self cheakUp];
    
//        NSLog(@"aaaaaaa---%d",[[NSFileManager defaultManager] removeItemAtPath:[[SandboxHelp GetdocumentsDirectory] stringByAppendingPathComponent:@"/game"] error:nil]);
//    NSLog(@"aaaaaaa---%d",[[NSFileManager defaultManager] removeItemAtPath:[[SandboxHelp GetdocumentsDirectory] stringByAppendingPathComponent:@"/_downloads"] error:nil]);
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [self startGame];
   
}





-(void)B_startGame:(NSString *)C_getConfig{
    
    NSArray *C_languages = [NSLocale preferredLanguages];
    NSString *C_currentLanguage = [C_languages objectAtIndex:0];
    NSLog(@"currentLanguage~~>>%@",C_currentLanguage);
    NSString *C_languageStr = C_currentLanguage;
    if ([C_currentLanguage hasPrefix:@"en-"]) {
        C_languageStr = @"en";
    }
    else if ([C_currentLanguage hasPrefix:@"zh-Hant-"]) {
        C_languageStr = @"tc";
    }
    else if ([C_currentLanguage hasPrefix:@"vi-"]) {
        C_languageStr = @"vi";
    }
    else if ([C_currentLanguage hasPrefix:@"id-"]) {
        C_languageStr = @"id";
    }
//    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//    NSString *str = [NSString setSafeString:[ud valueForKey:@"currentLanguage"]];
//    if (str.length>0) {
//        languageStr = str;
//    }
    
    NSString *C_uuid = [A_KeyChainStore B_getUUIDByKeyChain];
    NSURL* C_urlToDocumentsFolder = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        __autoreleasing NSError *C_error;
        NSDate *C_installDate = [[[NSFileManager defaultManager] attributesOfItemAtPath:C_urlToDocumentsFolder.path error:&C_error] objectForKey:NSFileCreationDate];
        NSLog(@"This app was installed by the user on %@ %zd", C_installDate, (NSInteger)[C_installDate timeIntervalSince1970]);
    
    NSString *C_identifier = [NSString B_setSafeString:[[NSBundle mainBundle] bundleIdentifier]];
    AppDelegate *C_appdelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    NSString *C_arguments = [NSString B_setSafeString:C_appdelegate.arguments];
    float C_safeArea = C_kIsBangsScreen?18.0*[UIScreen mainScreen].scale:0;
    NSString* C_gameUrl = [NSString stringWithFormat:@"http://tool.egret-labs.org/Weiduan/game/index.html?getConfig=%@&copyText=%@&packageName=%@&arguments=%@&model=%@&safeArea=%lf&supportedEtc=%d&lang=%@&appPlatformId=%@&version=%@&uuid=%@&installTime=%zd&agent=%@&sdk=SDKLog|Facebook|Zalo|Line&isSupportMicrophone=1",C_getConfig,[[NSString B_setSafeString:[[UIPasteboard generalPasteboard] string]] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],C_identifier,[C_arguments stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]],[A_JHHelp B_getCurrentDeviceModel],C_safeArea,[[NSUserDefaults standardUserDefaults] boolForKey:@"ishasEtc"],@"en",C_CHANNEL_ID,[[UIDevice currentDevice] systemVersion],C_uuid,(NSInteger)[C_installDate timeIntervalSince1970],[NSString B_setSafeString:[[NSUserDefaults standardUserDefaults]  valueForKey:@"vestgetconfigcodekey"]]];
        
    NSLog(@"identifier--->%@",C_gameUrl);
    
    NSLog(@"KeyChainStoreKeyChainStore~~~>>>%@",[A_KeyChainStore B_getUUIDByKeyChain]);
    
    _C_native = [[EgretNativeIOS alloc] init];
    _C_native.config.showFPS = NO;
    _C_native.config.fpsLogTime = 30;
    _C_native.config.disableNativeRender = YES;
    _C_native.config.clearCache = false;
    _C_native.config.useCutout = YES;
    
    NSString*C_testDirectory = [[A_SandboxHelp B_GetdocumentsDirectory] stringByAppendingPathComponent:@"/game"];
    
    _C_native.config.preloadPath = [NSString stringWithFormat:@"%@/",C_testDirectory];
    
    NSLog(@"_native.config.preloadPath-->%@",_C_native.config.preloadPath);
    
//    [self.view addSubview:[_native createEAGLView]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addEAGView" object:nil userInfo:@{@"EZGView":[_C_native createEAGLView]}];
    
    [self B_setExternalInterfaces];
    
    NSString* C_networkState = [_C_native getNetworkState];
    if ([C_networkState isEqualToString:@"NotReachable"]) {
        __block EgretNativeIOS* C_native = _C_native;
        [_C_native setNetworkStatusChangeCallback:^(NSString* C_state) {
            if (![C_state isEqualToString:@"NotReachable"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [C_native startGame:C_gameUrl];
                });
            }
        }];
    }
    [_C_native startGame:C_gameUrl];
}

- (void)B_setExternalInterfaces {
    __block EgretNativeIOS* support = _C_native;
    __weak A_UpBassController *C_mySelf = self;
    [_C_native setExternalInterface:@"sendToNative" Callback:^(NSString* C_message) {
        NSString* C_str = [NSString stringWithFormat:@"Native get message: %@", C_message];
        NSLog(@"%@", C_str);
        [support callExternalInterface:@"sendToJS" Value:C_str];
    }];
    [_C_native setExternalInterface:@"@onState" Callback:^(NSString *C_message) {
        NSLog(@"Get @onState: %@", C_message);
    }];
    [_C_native setExternalInterface:@"@onError" Callback:^(NSString *C_message) {
        NSLog(@"Get @onError: %@", C_message);
    }];
    [_C_native setExternalInterface:@"@onJSError" Callback:^(NSString *C_message) {
        NSLog(@"Get @onJSError: %@", C_message);
    }];
    [_C_native setExternalInterface:@"JsToNative" Callback:^(NSString *C_message) {
//        NSLog(@"Get @JsToNative: %@", message);
        [C_mySelf B_jsToNative:C_message];
    }];
//    [_native setExternalInterface:@"NativeToJs" Callback:^(NSString *message) {
//        NSLog(@"Get @onJSError: %@", message);
//    }];
}

-(void)B_jsToNative:(NSString *)C_msg{
//    NSLog(@"父类~~~%@",msg);
}

// - 事件处理
/** 程序进入前台 开始活跃 */
- (void)B_appBecomeActive {
    NSLog(@"appBecomeActive");
    [_C_native resume];
}

/** 程序进入后台 */
- (void)B_appEnterBackground {
    NSLog(@"appEnterBackground");
//    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    [_C_native pause];
}



- (void)dealloc {
    [_C_native destroy];
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidEnterBackgroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidBecomeActiveNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationWillTerminateNotification];
    
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures{
    return UIRectEdgeAll;
}

@end
