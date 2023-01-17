//
//  UIImage+setImageStrName.m
//  XGame(i_1)
//
//  Created by 叶建辉 on 2022/2/21.
//  Copyright © 2022 egret. All rights reserved.
//

#import "UIImage+A_setImageStrName.h"
#import "A_SandboxHelp.h"
@implementation UIImage (A_setImageStrName)
+(UIImage *)B_imageNameds:(NSString *)C_Str{
    return [[UIImage alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/platform/%@",[A_SandboxHelp B_GetdocumentsDirectory],[C_Str hasSuffix:@"jpg"]?C_Str:[NSString stringWithFormat:@"%@.png",C_Str]]];
}
@end
