//
//  MBProgressHUD+HSWW.m
//  HSWWWallpaper
//
//  Created by tusm on 16/6/4.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "MBProgressHUD+A_HSWW.h"

@implementation MBProgressHUD (A_HSWW)


+(void)B_showMessageBlack:(NSString *)C_message inView:(UIView *)C_view{
    if (C_view == nil){
        C_view = [UIApplication sharedApplication].keyWindow;
    }
    MBProgressHUD *C_hud = [MBProgressHUD showHUDAddedTo:C_view animated:YES];
    C_hud.color = [UIColor colorWithWhite:.1 alpha:1];
    C_hud.detailsLabelFont = [UIFont systemFontOfSize:14];
    C_hud.detailsLabelText = C_message;
    C_hud.detailsLabelColor = [UIColor whiteColor];
    C_hud.mode = MBProgressHUDModeCustomView;
    C_hud.removeFromSuperViewOnHide = YES;
    C_hud.userInteractionEnabled = NO;
    double C_seconds = 0.5;
    C_seconds += C_message.length*0.15;
    if (C_seconds>3.0) {
        C_seconds = 3.0;
    }
    if (C_seconds < 1) {
        C_seconds += 0.5;
    }
    [C_hud hide:YES afterDelay:C_seconds];
}

@end
