//
//  NSURLSession+TYCorrectedResumeData.m
//  TYDLManagerDemo
//
//  Created by tanyang on 2016/10/7.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "NSURLSession+A_TYCorrectedResumeData.h"
#import <UIKit/UIKit.h>

#define IS_IOS10ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)
#define IS_IOS11ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11)
#define IS_IOS12ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 12)

@implementation NSURLSession (A_TYCorrectedResumeData)

- (NSURLSessionDownloadTask *)B_DLTaskWithCorrectResumeData:(NSData *)C_resumeData {
    NSString *C_kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
    NSString *C_kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
    
    if (IS_IOS11ORLATER)
    {
        NSString * C_dataStr = [[NSString alloc]initWithData:C_resumeData encoding:NSUTF8StringEncoding];
        NSString * C_newStr = [self B_cleanResumeDataWithString:C_dataStr];
        C_resumeData = [C_newStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSData *C_cData = correctResumeData(C_resumeData);
    C_cData = C_cData?C_cData:C_resumeData;
    NSURLSessionDownloadTask *C_task = [self downloadTaskWithResumeData:C_cData];
    NSMutableDictionary *C_resumeDic = getResumeDictionary(C_cData);
    if (C_resumeDic) {
        if (C_task.originalRequest == nil) {
            NSData *C_originalReqData = C_resumeDic[C_kResumeOriginalRequest];
            NSURLRequest *C_originalRequest = [NSKeyedUnarchiver unarchiveObjectWithData:C_originalReqData ];
            if (C_originalRequest) {
                [C_task setValue:C_originalRequest forKey:@"originalRequest"];
            }
        }
        if (C_task.currentRequest == nil) {
            NSData *C_currentReqData = C_resumeDic[C_kResumeCurrentRequest];
            NSURLRequest *C_currentRequest = [NSKeyedUnarchiver unarchiveObjectWithData:C_currentReqData];
            if (C_currentRequest) {
                [C_task setValue:C_currentRequest forKey:@"currentRequest"];
            }
        }
        
    }
    return C_task;
}

#pragma mark- private

- (NSString *)B_cleanResumeDataWithString:(NSString *)C_dataStr
{
    if([C_dataStr containsString:@"<key>NSURLSessionResumeByteRange</key>"])
    {
        NSRange C_rangeKey  = [C_dataStr rangeOfString:@"<key>NSURLSessionResumeByteRange</key>"];
        NSString * C_headStr = [C_dataStr substringToIndex:C_rangeKey.location];
        NSString * C_backStr = [C_dataStr substringFromIndex:C_rangeKey.location];
        NSRange C_rangeValue = [C_backStr rangeOfString:@"</string>\n\t"];
        NSString * C_tailStr = [C_backStr substringFromIndex:C_rangeValue.location + C_rangeValue.length];
        C_dataStr = [C_headStr stringByAppendingString:C_tailStr];
    }
    return C_dataStr;
}


NSData * correctRequestData(NSData *C_data) {
    if (!C_data) {
        return nil;
    }
    // return the same data if it's correct
    if ([NSKeyedUnarchiver unarchiveObjectWithData:C_data] != nil) {
        return C_data;
    }
    NSMutableDictionary *C_archive = [[NSPropertyListSerialization propertyListWithData:C_data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil] mutableCopy];
    
    if (!C_archive) {
        return nil;
    }
    NSInteger C_k = 0;
    id C_objectss = C_archive[@"$objects"];
    while ([C_objectss[1] objectForKey:[NSString stringWithFormat:@"$%ld",C_k]] != nil) {
        C_k += 1;
    }
    NSInteger C_i = 0;
    while ([C_archive[@"$objects"][1] objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",C_i]] != nil) {
        NSMutableArray *C_arr = C_archive[@"$objects"];
        NSMutableDictionary *C_dic = C_arr[1];
        id C_obj = [C_dic objectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",C_i]];
        if (C_obj) {
            [C_dic setValue:C_obj forKey:[NSString stringWithFormat:@"$%ld",C_i+C_k]];
            [C_dic removeObjectForKey:[NSString stringWithFormat:@"__nsurlrequest_proto_prop_obj_%ld",C_i]];
            [C_arr replaceObjectAtIndex:1 withObject:C_dic];
            C_archive[@"$objects"] = C_arr;
        }
        C_i++;
    }
    if ([C_archive[@"$objects"][1] objectForKey:@"__nsurlrequest_proto_props"] != nil) {
        NSMutableArray *C_arr = C_archive[@"$objects"];
        NSMutableDictionary *C_dic = C_arr[1];
        id C_obj = [C_dic objectForKey:@"__nsurlrequest_proto_props"];
        if (C_obj) {
            [C_dic setValue:C_obj forKey:[NSString stringWithFormat:@"$%ld",C_i+C_k]];
            [C_dic removeObjectForKey:@"__nsurlrequest_proto_props"];
            [C_arr replaceObjectAtIndex:1 withObject:C_dic];
            C_archive[@"$objects"] = C_arr;
        }
    }
    // Rectify weird "NSKeyedArchiveRootObjectKey" top key to NSKeyedArchiveRootObjectKey = "root"
    if ([C_archive[@"$top"] objectForKey:@"NSKeyedArchiveRootObjectKey"] != nil) {
        [C_archive[@"$top"] setObject:C_archive[@"$top"][@"NSKeyedArchiveRootObjectKey"] forKey: NSKeyedArchiveRootObjectKey];
        [C_archive[@"$top"] removeObjectForKey:@"NSKeyedArchiveRootObjectKey"];
    }
    // Reencode archived object
    NSData *C_result = [NSPropertyListSerialization dataWithPropertyList:C_archive format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
    return C_result;
}

NSMutableDictionary *getResumeDictionary(NSData *data) {
    NSMutableDictionary *iresumeDictionary = nil;
    if (IS_IOS10ORLATER) {
        id root = nil;
        id  keyedUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        @try {
            root = [keyedUnarchiver decodeTopLevelObjectForKey:@"NSKeyedArchiveRootObjectKey" error:nil];
            if (root == nil) {
                root = [keyedUnarchiver decodeTopLevelObjectForKey:NSKeyedArchiveRootObjectKey error:nil];
            }
        } @catch(NSException *exception) {
            
        }
        [keyedUnarchiver finishDecoding];
        iresumeDictionary = [root mutableCopy];
    }
    
    if (iresumeDictionary == nil) {
        iresumeDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
    }
    return iresumeDictionary;
}

NSData *correctResumeData(NSData *data) {
    NSString *kResumeCurrentRequest = @"NSURLSessionResumeCurrentRequest";
    NSString *kResumeOriginalRequest = @"NSURLSessionResumeOriginalRequest";
    if (data == nil) {
        return  nil;
    }
    NSMutableDictionary *resumeDictionary = getResumeDictionary(data);
    if (resumeDictionary == nil) {
        return nil;
    }
    resumeDictionary[kResumeCurrentRequest] = correctRequestData(resumeDictionary[kResumeCurrentRequest]);
    resumeDictionary[kResumeOriginalRequest] = correctRequestData(resumeDictionary[kResumeOriginalRequest]);
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:resumeDictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    return result;
}

@end
