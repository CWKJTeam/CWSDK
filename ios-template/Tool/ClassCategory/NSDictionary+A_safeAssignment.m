//
//  NSDictionary+safeAssignment.m
//  QiMingJieMing
//
//  Created by Gufs on 17/1/24.
//  Copyright © 2017年 yjh. All rights reserved.
//

#import "NSDictionary+A_safeAssignment.h"

@implementation NSDictionary (A_safeAssignment)
+(NSString *)B_setSafeDictionary:(id)C_obj{
    if ([C_obj isKindOfClass:[NSDictionary class]]) {
        return C_obj;
    }
    return nil;
}
@end
