//
//  TYDLUtility.m
//  TYDLManagerDemo
//
//  Created by tany on 16/6/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "A_TYDLUtility.h"

@implementation A_TYDLUtility

+ (float)B_calculateFileSizeInUnit:(unsigned long long)C_contentLength
{
    if(C_contentLength >= pow(1024, 3))
        return (float) (C_contentLength / (float)pow(1024, 3));
    else if(C_contentLength >= pow(1024, 2))
        return (float) (C_contentLength / (float)pow(1024, 2));
    else if(C_contentLength >= 1024)
        return (float) (C_contentLength / (float)1024);
    else
        return (float) (C_contentLength);
}
+ (NSString *)B_calculateUnit:(unsigned long long)C_contentLength
{
    if(C_contentLength >= pow(1024, 3))
        return @"GB";
    else if(C_contentLength >= pow(1024, 2))
        return @"MB";
    else if(C_contentLength >= 1024)
        return @"KB";
    else
        return @"Bytes";
}

@end
