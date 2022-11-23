//
//  A_Tool.h
//  500117
//
//  Created by 肖家宝 on 2022/11/22.
//  Copyright © 2022 egret. All rights reserved.
//

#ifndef A_Tool_h
#define A_Tool_h

#import "UIViewController+A_Utility.h"
#import "UIWindow+A_Utility.h"
#import "UIView+A_Frame.h"
#import "NSString+A_safeAssignment.h"
#import "A_JHHelp.h"
#import "NSDictionary+A_safeAssignment.h"
#import "A_LocalWebServerManager.h"
#import "A_SandboxHelp.h"
#import "A_GameDal.h"
//#import "SSZipArchive.h"
#import "A_loadGif.h"
#import "A_JHProgressView.h"
#import "A_promptHelp.h"
#import "A_AFNetworkingClient.h"
#import "MBProgressHUD+A_HSWW.h"
#import "UIImage+A_setImageStrName.h"
//#import "Firebase.h"
//#import <LineSDK/LineSDK.h>
//#import <AppsFlyerLib/AppsFlyerLib.h>
#import "A_appReportExample.h"
#import "A_KeyChainStore.h"

#define VESTID @"500117"

#define CHANNELID @"33"
#define CHANNEL_ID @"33"


#define kZALO_SDK_APP_ID @"271573910171749274"
#define kApiHost @"https://www.vpwr4.com/"
//#define kApiHost @"https://game1dev3.gameyibang.cn/"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_PAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define SIX_DIV  [UIScreen mainScreen ].bounds.size.height/375
#define IPAD_BETWEEN 150
#define IPAD_BETWEENS 300

#define mcColor [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:.25]

#define WIDTHDiv  [UIScreen mainScreen ].bounds.size.width
#define HEIGHTDiv  [ UIScreen mainScreen ].bounds.size.height

#define E_DOWNLOAD @"Download"
#define E_EVENTLISTENER @"eventListener"
#define E_ZIP @"Zip"
#define E_DECOMPRESS @"decompress"
#define E_CLASS @"class"
#define E_FUNCTION @"function"
#define E_WKWEBVIEW @"Webview"

#define isIphoneX ({\
BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
    if (!UIEdgeInsetsEqualToEdgeInsets([UIApplication sharedApplication].delegate.window.safeAreaInsets, UIEdgeInsetsZero)) {\
    isPhoneX = YES;\
    }\
}\
isPhoneX;\
})

#define kIsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})

#endif /* A_Tool_h */

