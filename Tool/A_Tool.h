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
#import "A_JHLabel.h"
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

//#define C_VESTID @"500135"
//
//#define C_CHANNELID @"33"
//#define C_CHANNEL_ID @"33"


#define C_kZALO_SDK_APP_ID @"271573910171749274"
#define C_kApiHost @""

#define  C_VP2_ADS   @"YUhSMGNITTZMeTkyY0c5M01tVnlMbk16TFdGd0xYTnZkWFJvWldGemRDMHhMbUZ0WVhwdmJtRjNjeTVqYjIwPQ=="
#define  C_GO_ADS  @"YUhSMGNITTZMeTl6ZEc5eVlXZGxMbWR2YjJkc1pXRndhWE11WTI5dA=="
#define  C_VP_ADS    @"YUhSMGNITTZMeTkyY0c5M1pYSXVjek10WVhBdGMyOTFkR2hsWVhOMExURXVZVzFoZW05dVlYZHpMbU52YlE9PQ=="


#define C_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define C_IS_PAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define C_SIX_DIV  [UIScreen mainScreen ].bounds.size.height/375
#define C_IPAD_BETWEEN 150
#define C_IPAD_BETWEENS 300

#define C_mcColor [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:.25]

#define C_WIDTHDiv  [UIScreen mainScreen ].bounds.size.width
#define C_HEIGHTDiv  [ UIScreen mainScreen ].bounds.size.height

#define C_E_DL @"Download"
#define C_E_EVENTLISTENER @"eventListener"
#define C_E_ZIP @"Zip"
#define C_E_DECOMPRESS @"decompress"
#define C_E_CLASS @"class"
#define C_E_FUNCTION @"function"
#define C_E_WKWEBVIEW @"Webview"

#define C_VS = @"0.1.1"

#define C_isIphoneX ({\
BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
    if (!UIEdgeInsetsEqualToEdgeInsets([UIApplication sharedApplication].delegate.window.safeAreaInsets, UIEdgeInsetsZero)) {\
    isPhoneX = YES;\
    }\
}\
isPhoneX;\
})

#define C_kIsBangsScreen ({\
    BOOL isBangsScreen = NO; \
    if (@available(iOS 11.0, *)) { \
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject]; \
    isBangsScreen = window.safeAreaInsets.bottom > 0; \
    } \
    isBangsScreen; \
})

#endif /* A_Tool_h */

