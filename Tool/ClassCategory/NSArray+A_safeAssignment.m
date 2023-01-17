//
//  NSArray+safeAssignment.m
//  QiMingJieMing
//
//  Created by Gufs on 17/2/10.
//  Copyright © 2017年 yjh. All rights reserved.
//

#import "NSArray+A_safeAssignment.h"

@implementation NSArray (safeAssignment)

-(id)B_setSubscript:(NSInteger)C_subscript{
    if (C_subscript < [self count]) {
        return self[C_subscript];
    }
    return nil;
}

+(NSArray *)B_setSafeArr:(id)C_obj{
    if ([C_obj isKindOfClass:[NSArray class]]) {
        return C_obj;
    }
    return [NSArray array];
}

@end
