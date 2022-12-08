//
//  AFNetworkingClient.m
//  comic
//
//  Created by  on 14-4-14.
//  Copyright (c) 2014年 yixun. All rights reserved.
//

#import "A_AFNetworkingClient.h"
//#import "AFHTTPRequestOperationManager.h"
#import <CommonCrypto/CommonDigest.h>

@implementation A_AFNetworkingClient


-(NSString *)B_getErrorString:(NSError *)error
{
    NSString *strError;
    NSInteger urlErrorCode = -1009;
    if (error.code == urlErrorCode) {
        strError = @"请检查网络连接是否正常！";
    }
    else if(error.code == -1001)
    {
        strError = @"网络连接超时";
    }
    else if(error.code ==-1004)
    {
        strError = @"请检查网络连接是否正常！";
    }
    else
    {
        strError = [NSString stringWithFormat:@"网络访问出现异常，错误号：%ld",(long)error.code];
    }
    return strError;
}

// post
+(void)B_postWithPath:(NSString *)path WithParams:(NSDictionary *)params withCallBack:(HDCallBack)myCallback{
    NSString *fullUrl = path;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 10;
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [A_AFNetworkingClient setHeader:manager fullUrl:fullUrl];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager POST:fullUrl parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        myCallback(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        myCallback(error);
    }];
}

//Get
+(void)B_getWithPath:(NSString *)path withCallBack:(HDCallBack)myCallback
{
    NSString *fullUrl = path;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
//    [AFNetworkingClient setHeader:manager fullUrl:fullUrl];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager GET:fullUrl parameters:nil progress:^(NSProgress * _Nonnull DLProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        myCallback(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        myCallback(error);
    }];
}


+(void)setHeader:(AFHTTPSessionManager *)manager fullUrl:(NSString *)fullUrl
{
//    NSInteger timestampNow = [[NSDate date]timeIntervalSince1970];
//    NSInteger timesSpan = [[NSUserDefaults standardUserDefaults]integerForKey:kUserDefault_TimeSpan];
//    NSInteger ts = timestampNow -timesSpan;
//    NSString *strTs = [NSString stringWithFormat:@"%zd",ts];
//
//    NSString *appId =[NSString stringWithFormat:@"%d",kAppId];
//
//    NSArray *array = [fullUrl componentsSeparatedByString:@"?"];
//    NSString *param;
//    NSString *host;
//    if(array.count>0)
//    {
//        host = array[0];
//    }
//    else
//    {
//        host = fullUrl;
//    }
//    if(array.count>1)
//    {
//        param = array[1];
//    }
//    NSString *orderParam = [AFNetworkingClient getOrderParam:param];
//    NSString *sign = [AFNetworkingClient getSign:orderParam];
//    //NSString *requestUrl = [NSString stringWithFormat:@"%@?%@&app_sign=%@",host,orderParam,sign];
//    //NSLog(@"requestUrl=%@",requestUrl);
//    NSString *channelId = kChannelId;
//
//    NSString *device;
//    if(INTERFACE_IS_PAD)
//    {
//        device = @"pad";
//    }
//    else
//    {
//        device = @"mobile";
//    }
//
////    NSString *strUserId = [NSString stringWithFormat:@"%zd",[UserService instance].userId];
//
//    [manager.requestSerializer setValue:strTs forHTTPHeaderField:@"ts"];
//    [manager.requestSerializer setValue:appId forHTTPHeaderField:@"app-id"];
//    [manager.requestSerializer setValue:channelId forHTTPHeaderField:@"channel-id"];
//    [manager.requestSerializer setValue:sign forHTTPHeaderField:@"app-sign"];
    [manager.requestSerializer setValue:@"ios" forHTTPHeaderField:@"platform"];
    [manager.requestSerializer setValue:@"app" forHTTPHeaderField:@"client-type"];
}

+(NSString *)B_getOrderParam:(NSString *)param
{
    if(!param || [param isEqualToString:@""])
        return @"";
    NSMutableArray *arrKey  =[[NSMutableArray alloc]init];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
    NSArray *arrParam = [param componentsSeparatedByString:@"&"];
    for (int i=0; i<arrParam.count; i++) {
        NSString *strParam = arrParam[i];
        NSArray *arrChildParam = [strParam componentsSeparatedByString:@"="];
        if(arrChildParam.count>1)
        {
            NSString *key = arrChildParam[0];
            NSString *value = [A_AFNetworkingClient B_encodeParam:arrChildParam[1]];
            if(value && ![value isEqualToString:@""])
            {
                [arrKey addObject:key];
                [dict setObject:value forKey:key];
            }
        }
    }
    //按字母顺序排序
    NSArray *sortedArray = [arrKey sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    NSMutableString *mutableString = [[NSMutableString alloc]init];
    for (NSString *strKey in sortedArray) {
        NSString *value = [dict objectForKey:strKey];
        if(mutableString.length>0)
        {
            [mutableString appendFormat:@"&%@=%@",strKey,value];
        }
        else
        {
            [mutableString appendFormat:@"%@=%@",strKey,value];
        }
    }

    return mutableString;
}

+(NSString *)B_encodeParam:(NSString *)strValue
{
    NSString * charaters = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:charaters] invertedSet];
    NSString * hString2 = [strValue stringByAddingPercentEncodingWithAllowedCharacters:set];
    return hString2;
}



@end
