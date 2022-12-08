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
    AFHTTPSessionManager *C_manager = [AFHTTPSessionManager manager];
    C_manager.requestSerializer.timeoutInterval = 10;
    [C_manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [A_AFNetworkingClient setHeader:C_manager fullUrl:fullUrl];
    [C_manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [C_manager POST:fullUrl parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        myCallback(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        myCallback(error);
    }];
}

//Get
+(void)B_getWithPath:(NSString *)C_path withCallBack:(HDCallBack)C_myCallback
{
    NSString *C_fullUrl = C_path;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 20;
//    [AFNetworkingClient setHeader:manager fullUrl:fullUrl];
//    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [manager GET:C_fullUrl parameters:nil progress:^(NSProgress * _Nonnull DLProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
        C_myCallback(dic);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        C_myCallback(error);
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

+(NSString *)B_getOrderParam:(NSString *)C_param
{
    if(!C_param || [C_param isEqualToString:@""])
        return @"";
    NSMutableArray *C_arrKey  =[[NSMutableArray alloc]init];
    NSMutableDictionary * C_dict = [[NSMutableDictionary alloc]init];
    NSArray *C_arrParam = [C_param componentsSeparatedByString:@"&"];
    for (int i=0; i<C_arrParam.count; i++) {
        NSString *C_strParam = C_arrParam[i];
        NSArray *C_arrChildParam = [C_strParam componentsSeparatedByString:@"="];
        if(C_arrChildParam.count>1)
        {
            NSString *C_key = C_arrChildParam[0];
            NSString *C_value = [A_AFNetworkingClient B_encodeParam:C_arrChildParam[1]];
            if(C_value && ![C_value isEqualToString:@""])
            {
                [C_arrKey addObject:C_key];
                [C_dict setObject:C_value forKey:C_key];
            }
        }
    }
    //按字母顺序排序
    NSArray *C_sortedArray = [C_arrKey sortedArrayUsingComparator:^NSComparisonResult(id C_obj1, id C_obj2) {
        return [C_obj1 compare:C_obj2 options:NSNumericSearch];
    }];
    
    NSMutableString *C_mutableString = [[NSMutableString alloc]init];
    for (NSString *C_strKey in C_sortedArray) {
        NSString *C_value = [C_dict objectForKey:C_strKey];
        if(C_mutableString.length>0)
        {
            [C_mutableString appendFormat:@"&%@=%@",C_strKey,C_value];
        }
        else
        {
            [C_mutableString appendFormat:@"%@=%@",C_strKey,C_value];
        }
    }

    return C_mutableString;
}

+(NSString *)B_encodeParam:(NSString *)C_strValue
{
    NSString * C_charaters = @"?!@#$^&%*+,:;='\"`<>()[]{}/\\| ";
    NSCharacterSet * C_set = [[NSCharacterSet characterSetWithCharactersInString:C_charaters] invertedSet];
    NSString * C_hString2 = [C_strValue stringByAddingPercentEncodingWithAllowedCharacters:C_set];
    return C_hString2;
}



@end
