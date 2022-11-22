//
//  GameDal.m
//  vpower(i_1)
//
//  Created by 叶建辉 on 2021/12/8.
//  Copyright © 2021 egret. All rights reserved.
//

#import "A_GameDal.h"

#import "A_AFNetworkingClient.h"


@implementation A_GameDal

+(void)B_PostAppLoginReport:(NSString *)C_path andParams:(NSDictionary *)C_dic andBack:(AfBack)C_back{
    NSString *C_urlString =[NSString stringWithFormat:@"https://%@/api/dot/iosLogin?type=%@&device_number=%@&package=%@&report_time=%@&standard=%@",C_path,C_dic[@"type"],C_dic[@"device_number"],C_dic[@"package"],C_dic[@"report_time"],C_dic[@"standard"]];
    NSString *C_fullUrl = C_urlString;
    NSLog(@"urlString~~~~~~~~>>%@ dic------->>%@",C_urlString,C_dic);
    AFHTTPSessionManager *C_manager = [AFHTTPSessionManager manager];
    C_manager.requestSerializer.timeoutInterval = 3;
    [C_manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [C_manager GET:C_fullUrl parameters:nil progress:^(NSProgress * _Nonnull C_downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull C_task, id  _Nullable C_responseObject) {
        NSDictionary *C_dic = [NSJSONSerialization JSONObjectWithData:C_responseObject options:0 error:nil];
        NSLog(@"~~~~~~~~>>%@",C_dic);
    } failure:^(NSURLSessionDataTask * _Nullable C_task, NSError * _Nonnull C_error) {
    }];
}

+(void)B_PostAppReport:(NSString *)C_path andParams:(NSDictionary *)C_dic andBack:(AfBack)C_back{
    
    NSString *C_urlString =[NSString stringWithFormat:@"https://%@/api/LoginProc/timeDiff?action=appReport",C_path];
//    NSLog(@"time_diff---->%@",dic[@"time_diff"]);
    [self postWithPath:C_urlString WithParams:C_dic withCallBack:^(id C_obj) {
        if ([C_obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *C_dic = C_obj;
            if ([C_dic[@"err_code"] intValue] == 1000) {
                C_back(YES,C_dic);
                NSLog(@"msg---->%@",C_dic[@"message"]);
            }else{
                NSString *C_str = [NSString B_setSafeString:C_dic[@"msg"]];
                
                C_back(NO,C_str);
            }
        }else{
            C_back(NO,@"获取数据失败,请检查网络");
        }
    }];
}

// post
+(void)postWithPath:(NSString *)C_path WithParams:(NSDictionary *)C_params withCallBack:(HDCallBack)C_myCallback{
//    NSLog(@"path->%@",path);
    NSMutableDictionary *C_alldic = [NSMutableDictionary dictionary];
    NSMutableDictionary *C_dics = [NSMutableDictionary dictionary];
    for (NSString *C_key in [C_params allKeys]) {
        [C_dics setObject:C_params[C_key] forKey:C_key];
    }
    NSMutableString *C_str = [A_JHHelp B_reqDiction:C_dics];
    NSString *C_timestr = [A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]];
    [C_dics setObject:C_timestr forKey:@"stime"];
    [C_str appendString:C_timestr];
    [C_str appendString:@"CdO23vdMos23f9l3d2*z2"];
    [C_dics setObject:[A_JHHelp B_md5:C_str] forKey:@"sign"];
//    [_infoarrs addObject: dics];
    [C_alldic setObject:@[C_dics] forKey:@"client_info"];
//    NSLog(@"dic->%@",alldic);
    NSData *C_dataFriends = [NSJSONSerialization dataWithJSONObject:C_alldic options:NSJSONWritingPrettyPrinted error:nil];

    NSString *C_jsonString = [[NSString alloc] initWithData:C_dataFriends encoding:NSUTF8StringEncoding];
//    NSLog(@"jsonString->%@",jsonString);

    AFURLSessionManager *C_manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSMutableURLRequest *C_req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:C_path parameters:nil error:nil];

    C_req.timeoutInterval= 10;

    [C_req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [C_req setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [C_req setHTTPBody:[C_jsonString dataUsingEncoding:NSUTF8StringEncoding]];

    [[C_manager dataTaskWithRequest:C_req completionHandler:^(NSURLResponse * _Nonnull C_response, id  _Nullable C_responseObject, NSError * _Nullable C_error) {

    if (!C_error) {

    

    if ([C_responseObject isKindOfClass:[NSDictionary class]]) {

        NSDictionary *C_dic = C_responseObject;
//        NSLog(@"dic: %@  ---%@", dic,dic[@"message"]);
        C_myCallback(C_dic);
    }

    } else {

    NSLog(@"Error: %@, %@, %@", C_error, C_response, C_responseObject);

    }

    }] resume];
}


+(void)B_GetHostHead:(GameBack)C_back{
    NSString *C_path1 = [NSString stringWithFormat:@"https://vpow2er.s3-ap-southeast-1.amazonaws.com/domain/%@.json?ver=%@",CHANNEL_ID,[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]]];
   
    NSString *C_path2 = [NSString stringWithFormat:@"https://storage.googleapis.com/vpower88/%@.json?ver=%@",CHANNEL_ID,[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]]];
    
    for (int C_i= 0; C_i < 6; C_i++) {
        NSString *C_urlstr = C_path1;
        if(C_i > 2){
            C_urlstr = C_path2;
        }
        [self B_getWithPath:C_urlstr withCallBack:^(BOOL C_success, id  _Nonnull C_obj) {
            if (!C_success) {
                NSInteger C_hosterrornum = [[NSUserDefaults standardUserDefaults] integerForKey:@"hosterrornum"];
                C_hosterrornum++;
                [[NSUserDefaults standardUserDefaults] setInteger:C_hosterrornum forKey:@"hosterrornum"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if(C_hosterrornum == 6){
                    C_back(@"C001");
                    NSError *C_erreos = C_obj;
                    [[A_appReportExample B_sharedInstance].C_mutArrs addObject:@{@"time_diff":@"0",@"event":@"10",@"status":@"0",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":@(C_erreos.code),@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":[NSString stringWithFormat:@"https://storage.googleapis.com/vpower88/%@.json",CHANNEL_ID],@"is_native":@"1"}]}];
                }
            }else{
                NSInteger C_hostfinishnum = [[NSUserDefaults standardUserDefaults] integerForKey:@"gethostfinishnum"];
                if(!C_hostfinishnum){
                    C_hostfinishnum++;
                    [[NSUserDefaults standardUserDefaults] setInteger:C_hostfinishnum forKey:@"gethostfinishnum"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    C_back(C_obj);
                }
            }
            NSInteger C_hostnum = [[NSUserDefaults standardUserDefaults] integerForKey:@"onehostnum"];
            C_hostnum++;
            [[NSUserDefaults standardUserDefaults] setInteger:C_hostnum forKey:@"onehostnum"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if(C_hostnum == 6){
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"hosterrornum"];
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"gethostfinishnum"];
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"onehostnum"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
        
    }
}
+(void)B_getWithPath:(NSString *)C_path withCallBack:(AfBack)C_myCallback
{
    NSString *C_fullUrl = C_path;
    AFHTTPSessionManager *C_manager = [AFHTTPSessionManager manager];
    C_manager.requestSerializer.timeoutInterval = 3;
    [C_manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [C_manager GET:C_fullUrl parameters:nil progress:^(NSProgress * _Nonnull C_downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull C_task, id  _Nullable C_responseObject) {
        NSDictionary *C_dic = [NSJSONSerialization JSONObjectWithData:C_responseObject options:0 error:nil];
        C_myCallback(YES,C_dic[CHANNEL_ID]);
    } failure:^(NSURLSessionDataTask * _Nullable C_task, NSError * _Nonnull C_error) {
        C_myCallback(NO,C_error);
    }];
}

+(void)B_GetAppConfigWithPath:(NSString *)C_path andBack:(GameBack)C_back{
    [self B_getConfigWithPath:C_path withCallBack:^(BOOL C_success, id  _Nonnull C_obj) {
        if(C_success){
            if ([[NSString B_setSafeString:C_obj[@"Code"]] integerValue] == 20000) {
                C_back(C_obj);
            }else{
                [[A_appReportExample B_sharedInstance].C_mutArrs addObject:@{@"time_diff":@"0",@"event":@"11",@"status":@"3",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":@([[NSString B_setSafeString:C_obj[@"Code"]] integerValue]),@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":C_path,@"is_native":@"1"}]}];
            }
        }else{
            NSError *C_erreos = C_obj;
            [[A_appReportExample B_sharedInstance].C_mutArrs addObject:@{@"time_diff":@"0",@"event":@"11",@"status":@"3",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":[NSString B_setSafeString:@(C_erreos.code)],@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":C_path,@"is_native":@"1"}]}];
            [self B_getConfigWithPath:C_path withCallBack:^(BOOL C_success, id  _Nonnull obj) {
                if(C_success){
                    if ([[NSString B_setSafeString:obj[@"Code"]] integerValue] == 20000) {
                        C_back(obj);
                    }else{
                        [[A_appReportExample B_sharedInstance].C_mutArrs addObject:@{@"time_diff":@"0",@"event":@"11",@"status":@"3",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":@([[NSString B_setSafeString:obj[@"Code"]] integerValue]),@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":C_path,@"is_native":@"1"}]}];
                    }
                }else{
                    NSError *C_erreos = C_obj;
                    [[A_appReportExample B_sharedInstance].C_mutArrs addObject:@{@"time_diff":@"0",@"event":@"11",@"status":@"3",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":[NSString B_setSafeString:@(C_erreos.code)],@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":C_path,@"is_native":@"1"}]}];
                    [self B_getConfigWithPath:C_path withCallBack:^(BOOL C_success, id  _Nonnull C_obj) {
                        if(C_success){
                            if ([[NSString B_setSafeString:obj[@"Code"]] integerValue] == 20000) {
                                C_back(C_obj);
                            }else{
                                C_back(@"C003");
                                [[A_appReportExample B_sharedInstance].C_mutArrs addObject:@{@"time_diff":@"0",@"event":@"11",@"status":@"3",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":@([[NSString B_setSafeString:C_obj[@"Code"]] integerValue]),@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":C_path,@"is_native":@"1"}]}];
                            }
                        }else{
                            C_back(@"C004");
                            NSError *C_erreos = C_obj;
                            [[A_appReportExample B_sharedInstance].C_mutArrs addObject:@{@"time_diff":@"0",@"event":@"11",@"status":@"0",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":[NSString B_setSafeString:@(C_erreos.code)],@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":C_path,@"is_native":@"1"}]}];
                        }
                    }];
                }
            }];
        }
    }];
}

+(void)B_getConfigWithPath:(NSString *)C_path withCallBack:(AfBack)C_myCallback{
    NSString *C_fullUrl = C_path;
    AFHTTPSessionManager *C_manager = [AFHTTPSessionManager manager];
    C_manager.requestSerializer.timeoutInterval = 3;
    [C_manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
    [C_manager GET:C_fullUrl parameters:nil progress:^(NSProgress * _Nonnull C_downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull C_task, id  _Nullable C_responseObject) {
        NSDictionary *C_dic = [NSJSONSerialization JSONObjectWithData:C_responseObject options:0 error:nil];
        C_myCallback(YES,C_dic);
    } failure:^(NSURLSessionDataTask * _Nullable C_task, NSError * _Nonnull C_error) {
        C_myCallback(NO,C_error);
    }];
}

+(void)B_GetLastInfoWithPath:(NSString *)C_path andBack:(GameBack)C_back{
    [self B_getConfigWithPath:C_path withCallBack:^(BOOL C_success, id  _Nonnull C_obj) {
        if(C_success){
            C_back(C_obj);
        }else{
            NSError *C_erreos = C_obj;
            [[A_appReportExample B_sharedInstance].C_apithrees addObject:@{@"time_diff":@"0",@"event":@"12",@"status":@"3",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":[NSString B_setSafeString:@(C_erreos.code)],@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":C_path,@"is_native":@"1"}]}];
            [self B_getConfigWithPath:C_path withCallBack:^(BOOL success, id  _Nonnull obj) {
                if(C_success){
                    C_back(C_obj);
                }else{
                    NSError *C_erreos = C_obj;
                    [[A_appReportExample B_sharedInstance].C_apithrees addObject:@{@"time_diff":@"0",@"event":@"12",@"status":@"3",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":[NSString B_setSafeString:@(C_erreos.code)],@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":C_path,@"is_native":@"1"}]}];
                    [self B_getConfigWithPath:C_path withCallBack:^(BOOL C_success, id  _Nonnull C_obj) {
                        if(C_success){
                            C_back(C_obj);
                        }else{
                            C_back(@"C002");
                            NSError *C_erreos = C_obj;
                            [[A_appReportExample B_sharedInstance].C_apithrees addObject:@{@"time_diff":@"0",@"event":@"12",@"status":@"0",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":[NSString B_setSafeString:@(C_erreos.code)],@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":C_path,@"is_native":@"1"}]}];
                        }
                    }];
                }
            }];
        }
    }];
}

@end
