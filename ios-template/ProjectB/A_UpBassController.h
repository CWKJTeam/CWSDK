//
//  UpBassController.h
//  vpower(i_1)
//
//  Created by 叶建辉 on 2021/12/10.
//  Copyright © 2021 egret. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EgretNativeIOS.h>
#import <WebKit/WebKit.h>
#import "AppDelegate.h"
NS_ASSUME_NONNULL_BEGIN

@interface A_UpBassController : UIViewController
@property(nonatomic,strong)EgretNativeIOS* C_native;

-(void)B_startGame:(NSString *)C_getConfig;
@end

NS_ASSUME_NONNULL_END
