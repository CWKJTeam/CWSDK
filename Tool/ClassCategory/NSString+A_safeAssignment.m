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
//base64加密
+(NSString *)B_setThicken:(NSString *)C_str{
       NSData *C_data = [C_str dataUsingEncoding:NSUTF8StringEncoding];
       NSData *C_b6Data = [C_data base64EncodedDataWithOptions:0];
       NSString *C_b6Str = [C_b6Data base64EncodedStringWithOptions:0];
       return C_b6Str;
}
//base64解密
+(NSString *)B_getDecrypt:(NSString *)C_b6str{

    NSData * C_b6data = [[NSData alloc] initWithBase64EncodedString:C_b6str options:0];
    NSData * C_data = [[NSData alloc] initWithBase64EncodedData:C_b6data options:0];
    NSString * C_str = [[NSString alloc] initWithData:C_data encoding:0];
    return C_str;
    
      
}

@end
