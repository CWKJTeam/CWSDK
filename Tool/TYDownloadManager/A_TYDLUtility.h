//
//  TYDLUtility.h
//  TYDLManagerDemo
//
//  Created by tany on 16/6/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  下载工具类
 */
@interface A_TYDLUtility : NSObject

// 返回文件大小
+ (float)B_calculateFileSizeInUnit:(unsigned long long)C_contentLength;

// 返回文件大小的单位
+ (NSString *)B_calculateUnit:(unsigned long long)C_contentLength;

@end
