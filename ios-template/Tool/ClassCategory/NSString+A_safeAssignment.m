//
//  NSString+safeAssignment.m
//  HSWWWallpaper
//
//  Created by tusm on 16/10/11.
//  Copyright © 2016年 tusm. All rights reserved.
//

#import "NSString+A_safeAssignment.h"

@implementation NSString (A_safeAssignment)

+(NSString *)B_setSafeString:(id)C_obj{
    if ([C_obj isKindOfClass:[NSString class]]) {
        return C_obj;
    }
    if ([C_obj isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@",C_obj];
    }
    return @"";
}

@end
