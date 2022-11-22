//
//  appReportExample.m
//  GoldenDragon(i_1)
//
//  Created by 叶建辉 on 2022/6/1.
//  Copyright © 2022 egret. All rights reserved.
//

#import "A_appReportExample.h"

@implementation A_appReportExample


+ (instancetype)B_sharedInstance{
    static A_appReportExample *C_myInstance = nil;
    if(C_myInstance == nil){
        C_myInstance = [[A_appReportExample alloc]init];
    }
    return C_myInstance;
}


@end
