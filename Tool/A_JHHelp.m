//
//  JHHelp.m
//  EmptyProject
//
//  Created by 叶建辉 on 2021/12/1.
//

#import "A_JHHelp.h"
#import "sys/utsname.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import "A_AFNetworkingClient.h"
#import "A_Reachability.h"
#import "AFURLSessionManager.h"

@implementation A_JHHelp

+(NSString*)B_generateCodeVerifier {
    uint8_t randomBytes[32];
    
    int result = SecRandomCopyBytes(kSecRandomDefault, 32, randomBytes);
    
    if (result == 0) {
        NSData *data = [[NSData alloc] initWithBytes:randomBytes length:32];
        
        NSString *base64 = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
        
        base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
        base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        base64 = [base64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
        base64 = [base64 stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        return base64;
    }
    
    return nil;
}

+ (NSString*)B_generateCodeChallenge:(NSString*)C_codeVerifier {
    NSData *C_data = [C_codeVerifier dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(C_data.bytes, (CC_LONG)C_data.length, result);
    
    NSData *C_hashed = [NSData dataWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
    
    NSString *C_base64 = [C_hashed base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    
    C_base64 = [C_base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    C_base64 = [C_base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    C_base64 = [C_base64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
    C_base64 = [C_base64 stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    return C_base64;
}

    


+(NSString *)B_getProjBVersion{
    NSString *C_curVersion = [NSString string];
    //沙盒版本文件地址
    NSString *C_sandBox = [NSString stringWithFormat:@"%@/game/resource/global.json",[A_SandboxHelp B_GetdocumentsDirectory]];
    //沙盒文件版本号
    if ([A_SandboxHelp B_isExistsAtPath:C_sandBox]) {
        NSLog(@"sandBox~~>>%@",C_sandBox);
        C_curVersion = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:C_sandBox] options:kNilOptions error:nil][@"version"];
    }else{
        //项目版本文件地址
        NSString *C_project = [NSString stringWithFormat:@"%@/game/resource/global.json",[[NSBundle mainBundle]resourcePath]];
        //项目文件版本号
        if ([A_SandboxHelp B_isExistsAtPath:C_project]) {
            NSLog(@"project~~>>%@",C_project);
            C_curVersion = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:C_project] options:kNilOptions error:nil][@"version"];
        }
    }
    
    if (C_curVersion.length == 0) {
        return @"";
    }
    return C_curVersion;
}
+(NSString*)dencode:(NSString*)C_base64String{
    NSData *C_data = [[NSData alloc]initWithBase64EncodedString:C_base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [[NSString alloc]initWithData:C_data encoding:NSUTF8StringEncoding];
}

+(void)B_GetimportantInformation:(McBack)C_back{
    NSString *C_urlString =[NSString stringWithFormat:@"%@api/game/getconfig?channel_id=%@&vest_id=%@&is_vest=1&ctype=1",C_kApiHost,C_CHANNELID,C_VESTID];
    NSLog(@"urlString---->%@",C_urlString);
    [A_AFNetworkingClient B_getWithPath:C_urlString withCallBack:^(id obj) {
//        NSLog(@"GetimportantInformation---->>%@",obj);
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *C_dic = obj;
            
            if ([C_dic[@"Code"] intValue] == 20000) {
                NSString *C_strrrr = [self dencode:[NSString B_setSafeString:C_dic[@"Data"]]];
                NSDictionary *C_dicssss = [NSJSONSerialization JSONObjectWithData:[C_strrrr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
                BOOL isvest = [C_dicssss[@"vestUpdateStatus"] boolValue];
                [[NSUserDefaults standardUserDefaults] setValue:[NSString B_setSafeString:C_dicssss[@"code"]] forKey:@"vestgetconfigcodekey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                NSLog(@"dicssss-->>%@",C_dicssss);
                NSLog(@"isvest---->>%@",isvest?@"yyy":@"nnn");
                C_back(@(isvest));
            }else{
                C_back(@(0));
            }
        }else{
            C_back(@(0));
        }
    }];

}

+(NSInteger)B_compareDate:(NSDate *)C_date1 andDate2:(NSDate *)C_date2{
    
    
    NSDateFormatter *C_dateFormatter = [[NSDateFormatter alloc] init];
    [C_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    
    NSLog(@"%@",[C_dateFormatter stringFromDate:C_date1]);
    NSLog(@"%@",[C_dateFormatter stringFromDate:C_date2]);
    
    NSCalendar *C_cal = [NSCalendar currentCalendar];

        

        unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond|NSCalendarUnitNanosecond;

        

        NSDateComponents *C_d = [C_cal components:unitFlags fromDate:C_date1 toDate:C_date2 options:0];

        

//    NSInteger hour = [d hour] + [d minute]/60 + [d second]/3600;

        return [C_d nanosecond]/1000000;
}

+(UIFont *)B_getFontWithUnderSix:(float)C_underSix{
    
    CGFloat C_proportion = C_SIX_DIV;
    
    if (C_IS_IPAD) {
        C_proportion = (C_WIDTHDiv-C_IPAD_BETWEENS)/375;
    }
    
    return [UIFont systemFontOfSize:C_underSix*C_proportion];
}

+(UIFont *)B_getboldFontWithUnderSix:(float)C_underSix{
    
    CGFloat C_proportion = C_SIX_DIV;
    
    if (C_IS_IPAD) {
        C_proportion = (C_WIDTHDiv-C_IPAD_BETWEENS)/375;
    }
    
    return [UIFont boldSystemFontOfSize:C_underSix*C_proportion];
}

+(NSString *)B_convertToJsonData:(NSDictionary *)C_dict

{

    NSError *C_error;

    NSData *C_jsonData = [NSJSONSerialization dataWithJSONObject:C_dict options:NSJSONWritingPrettyPrinted error:&C_error];

    NSString *C_jsonString;

    if (!C_jsonData) {

        NSLog(@"%@",C_error);

    }else{

        C_jsonString = [[NSString alloc]initWithData:C_jsonData encoding:NSUTF8StringEncoding];

    }

    NSMutableString *C_mutStr = [NSMutableString stringWithString:C_jsonString];

    NSRange C_range = {0,C_jsonString.length};

    //去掉字符串中的空格

    [C_mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:C_range];

    NSRange C_range2 = {0,C_mutStr.length};

    //去掉字符串中的换行符

    [C_mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:C_range2];

    return C_mutStr;

}

+ (NSDictionary *)B_dictionaryWithJsonString:(NSString *)C_jsonString
{
    if (C_jsonString == nil) {
        return nil;
    }

    NSData *C_jsonData = [C_jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *C_err;
    NSDictionary *C_dic = [NSJSONSerialization JSONObjectWithData:C_jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&C_err];
    if(C_err)
    {
        NSLog(@"json解析失败：%@",C_err);
        return nil;
    }
    return C_dic;
}

+(BOOL)B_compareVersion:(NSString *)C_v1 v2:(NSString *)C_v2{
    
    NSArray *C_a = [C_v1 componentsSeparatedByString:@"."];
    NSArray *C_b = [C_v2 componentsSeparatedByString:@"."];
    
    if([C_a[1] integerValue] > [C_b[1] integerValue]){
        return YES;
    }
    if([C_a[2] integerValue] > [C_b[2] integerValue]){
        return YES;
    }
    else if ([C_a[2] integerValue] == [C_b[2] integerValue]){
        if([C_a[3] integerValue] > [C_b[3] integerValue]){
            return YES;
        }
    }
    
    return NO;
}

+(void)B_DLResourcesWithUrl:(NSString *)C_url DLing:(McBack)C_jhprogress DLEnd:(McBack)C_back{
    NSURL *C_URL = [NSURL URLWithString:C_url];
    NSURLSessionConfiguration *C_configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *C_manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:C_configuration];
    
    NSURLRequest *C_request = [NSURLRequest requestWithURL:C_URL];
    NSURLSessionDownloadTask *C__DLTask = [C_manager downloadTaskWithRequest:C_request progress:^(NSProgress * _Nonnull DLProgress) {
        if (DLProgress) {
            
            C_jhprogress(@(1.0 * DLProgress.completedUnitCount / DLProgress.totalUnitCount));
            
//            NSLog(@"这个进度为%f",1.0 * DLProgress.completedUnitCount / DLProgress.totalUnitCount);
        }
        
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //- block的返回值, 要求返回一个URL, 返回的这个URL就是文件的位置的路径
        
        NSString *C_cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *C_path = [C_cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:C_path];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        // filePath就是你下载文件的位置，你可以解压，也可以直接拿来使用
        NSString *C_imgFilePath = [filePath path];// 将NSURL转成NSString
        //        UIImage *img = [UIImage imageWithContentsOfFile:imgFilePath];
    
        
        C_back(C_imgFilePath);
        
    }];
    [C__DLTask resume];
}

+(NSInteger)B_determineNetwork{
    NSInteger C_isExistenceNetwork = YES;
    A_Reachability *C_reach = [A_Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([C_reach currentReachabilityStatus]) {
        case NotReachable:
            C_isExistenceNetwork = 0;
            break;
        case ReachableViaWiFi:
            C_isExistenceNetwork = 1;
            break;
        case ReachableViaWWAN:
            C_isExistenceNetwork = 2;
            break;
    }
    if (!C_isExistenceNetwork) {
        return 0;
    }
    return C_isExistenceNetwork;
}

+(BOOL)B_isDateyear:(NSInteger)C_y mon:(NSInteger)C_m day:(NSInteger)C_d{
    NSDateFormatter *C_year = [[NSDateFormatter alloc] init];
        [C_year setDateFormat:@"yyyy"];
        NSInteger C_yearTime = [[C_year stringFromDate:[NSDate date]] integerValue];
    NSDateFormatter *C_mon = [[NSDateFormatter alloc] init];
        [C_mon setDateFormat:@"MM"];
    NSInteger C_monTime = [[C_mon stringFromDate:[NSDate date]] integerValue];
    NSDateFormatter *day = [[NSDateFormatter alloc] init];
        [day setDateFormat:@"dd"];
    NSInteger C_dayTime = [[day stringFromDate:[NSDate date]] integerValue];
//    NSLog(@"%zd:%zd:%zd",yearTime,monTime,dayTime);
    if(C_yearTime > C_y){
        return NO;
    }else{
        if(C_yearTime == C_y){
            if(C_monTime > C_m){
                return NO;
            }else{
                if(C_monTime == C_m){
                    if (C_dayTime>C_d) {
                        return NO;
                    }
                }
            }
        }
    }
    return YES;
}


+(BOOL)B_isAccident{
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"isRunAorB"] == 0){
        NSString *C_a = C_VESTID;
        NSString *C_b = [[UIPasteboard generalPasteboard] string];
        if([C_a isEqualToString:C_b]){
            [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"isRunAorB"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return NO;
        }
    }else{
        return NO;
    }
    return YES;
}

+(void)setLoginParame:(NSMutableDictionary *)C_dicParame;
{
    [C_dicParame setObject:C_VESTID forKey:@"vest_id"];
    [C_dicParame setObject:C_CHANNELID forKey:@"channel_id"];
    NSMutableString *str = [self B_reqDiction:C_dicParame];
    NSString *timestr = [self B_transTotimeSp:[self B_getNowTimeTimestamp]];
    [C_dicParame setObject:timestr forKey:@"stime"];
    [str appendString:timestr];
    [str appendString:@"CdO23vdMos23f9l3d2*z2"];
    [C_dicParame setObject:[self B_md5:str] forKey:@"sign"];
}

+ (NSMutableString *)B_reqDiction:(NSDictionary *)C_dict{
 
    NSArray *C_allKeyArray = [C_dict allKeys];
    NSArray *C_afterSortKeyArray = [C_allKeyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSComparisonResult resuest = [obj1 compare:obj2];  //[obj2 compare:obj1];降序
        return resuest;
    }];
    NSMutableString *C_valueArray = [NSMutableString string];
    for (NSString *sortsing in C_afterSortKeyArray) {
        NSString *valueString = [C_dict objectForKey:sortsing];
        [C_valueArray appendString:valueString];
    }
 
    return C_valueArray;
}

+(NSString *)B_transTotimeSp:(NSString *)C_time{
    NSDateFormatter *C_dateFormatter = [[NSDateFormatter alloc] init];
    [C_dateFormatter setTimeZone:[NSTimeZone systemTimeZone]]; //设置本地时区
    [C_dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *C_date = [C_dateFormatter dateFromString:C_time];
    NSString *C_timeSp = [NSString stringWithFormat:@"%ld", (long)[C_date timeIntervalSince1970]];//时间戳
    return C_timeSp;
}

+ (NSString *)B_getNowTimeTimestamp{
    NSDate *C_datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSDateFormatter *C_formatter = [[NSDateFormatter alloc] init];
    [C_formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [C_formatter setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *C_dateString = [C_formatter stringFromDate: C_datenow];
    return C_dateString;
}

+ (NSString *) B_md5:(NSString *) C_str
{
    const char *cStr = [C_str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+(void)B_PostLoginAndDotReport{
    
    NSMutableArray *C__infoarrs = [NSMutableArray array];
    
    NSUserDefaults *C_ud = [NSUserDefaults standardUserDefaults];
    if([[C_ud objectForKey:@"appStarNumber"] integerValue] == 0){
        [C_ud setObject:[NSString stringWithFormat:@"%d",0] forKey:@"appStarNumber"];
        [C_ud setObject:[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]] forKey:@"logout_time"];
        [C_ud synchronize];
    }
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"sessionToken"]){
        [A_JHHelp GetLogin:^(id  _Nonnull obj) {
            {
                NSMutableDictionary *C_dics = [NSMutableDictionary dictionary];
                [C_dics setValue:C_CHANNELID forKey:@"channel_id"];
                [C_dics setValue:C_VESTID forKey:@"vest_id"];
                
                [C_dics setValue:[self B_transTotimeSp:[self B_getNowTimeTimestamp]] forKey:@"login_time"];
                [C_dics setValue:[self B_getCurrentDeviceModel] forKey:@"device"];
                
                [C_dics setValue:[[UIDevice currentDevice] systemVersion] forKey:@"os"];
                [C_dics setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"imei"];
                
                [C_dics setValue:@"app" forKey:@"frm"];
                [C_dics setValue:[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]] forKey:@"ctime"];
                
                [C_dics setValue:[C_ud objectForKey:@"sessionToken"] forKey:@"token"];
                [C_dics setValue:[C_ud objectForKey:@"uid"] forKey:@"uid"];
                
                [C_dics setValue:[C_ud objectForKey:@"appStarNumber"] forKey:@"dot_num"];
                [C_dics setValue:[NSString stringWithFormat:@"%@ - %@",[C_ud objectForKey:@"last_scene"],[NSString B_setSafeString:[[NSBundle mainBundle] bundleIdentifier]]] forKey:@"last_scene"];
                
                [C_dics setValue:[C_ud objectForKey:@"logout_time"] forKey:@"logout_time"];
                
                NSMutableString *C_str = [A_JHHelp B_reqDiction:C_dics];
                NSString *C_timestr = [A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]];
                [C_dics setObject:C_timestr forKey:@"stime"];
                [C_str appendString:C_timestr];
                [C_str appendString:@"CdO23vdMos23f9l3d2*z2"];
                [C_dics setObject:[A_JHHelp B_md5:C_str] forKey:@"sign"];
                [C__infoarrs addObject: C_dics];
            }
        }];
    }else{
        [A_JHHelp PostLoginWithdic:[NSMutableDictionary dictionary] andMcBack:^(id  _Nonnull obj) {
            
            if([obj isKindOfClass:[NSDictionary class]]){
            [[NSUserDefaults standardUserDefaults] setObject:[NSString B_setSafeString:obj[@"sessionToken"]] forKey:@"sessionToken"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString B_setSafeString:obj[@"uid"]] forKey:@"uid"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString B_setSafeString:obj[@"Username"]] forKey:@"Username"];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString B_setSafeString:obj[@"pwd"]] forKey:@"password"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                {
                    NSMutableDictionary *C_dics = [NSMutableDictionary dictionary];
                    [C_dics setValue:C_CHANNELID forKey:@"channel_id"];
                    [C_dics setValue:C_VESTID forKey:@"vest_id"];
                    
                    [C_dics setValue:[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]] forKey:@"login_time"];
                    [C_dics setValue:[A_JHHelp B_getCurrentDeviceModel] forKey:@"device"];
                    
                    [C_dics setValue:[[UIDevice currentDevice] systemVersion] forKey:@"os"];
                    [C_dics setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"imei"];
                    
                    [C_dics setValue:@"app" forKey:@"frm"];
                    [C_dics setValue:[A_JHHelp B_transTotimeSp:[self B_getNowTimeTimestamp]] forKey:@"ctime"];
                    
                    [C_dics setValue:[C_ud objectForKey:@"sessionToken"] forKey:@"token"];
                    [C_dics setValue:[C_ud objectForKey:@"uid"] forKey:@"uid"];
                    
                    [C_dics setValue:[C_ud objectForKey:@"appStarNumber"] forKey:@"dot_num"];
                    [C_dics setValue:[NSString stringWithFormat:@"%@ - %@",[C_ud objectForKey:@"last_scene"],[NSString B_setSafeString:[[NSBundle mainBundle] bundleIdentifier]]] forKey:@"last_scene"];
                    [C_dics setValue:[C_ud objectForKey:@"logout_time"] forKey:@"logout_time"];
                    
                    NSMutableString *C_str = [A_JHHelp B_reqDiction:C_dics];
                    NSString *C_timestr = [A_JHHelp B_transTotimeSp:[self B_getNowTimeTimestamp]];
                    [C_dics setObject:C_timestr forKey:@"stime"];
                    [C_str appendString:C_timestr];
                    [C_str appendString:@"CdO23vdMos23f9l3d2*z2"];
                    [C_dics setObject:[A_JHHelp B_md5:C_str] forKey:@"sign"];
                    [C__infoarrs addObject: C_dics];
                }
            }else{
                return;
            }
            }];
    }
    
    
    
    
    [NSTimer scheduledTimerWithTimeInterval:60 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if(C__infoarrs.count == 2){
            [C__infoarrs removeObjectAtIndex:0];
        }
        NSMutableDictionary *C_dics = [NSMutableDictionary dictionary];
        [C_dics setValue:C_CHANNELID forKey:@"channel_id"];
        [C_dics setValue:C_VESTID forKey:@"vest_id"];
        
        [C_dics setValue:[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]] forKey:@"login_time"];
        [C_dics setValue:[A_JHHelp B_getCurrentDeviceModel] forKey:@"device"];
        
        [C_dics setValue:[[UIDevice currentDevice] systemVersion] forKey:@"os"];
        [C_dics setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"imei"];
        
        [C_dics setValue:@"app" forKey:@"frm"];
        [C_dics setValue:[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]] forKey:@"ctime"];
        
        [C_dics setValue:[C_ud objectForKey:@"sessionToken"] forKey:@"token"];
        [C_dics setValue:[C_ud objectForKey:@"uid"] forKey:@"uid"];
        
        [C_dics setValue:[C_ud objectForKey:@"appStarNumber"] forKey:@"dot_num"];
        [C_dics setValue:[NSString stringWithFormat:@"%@ - %@",[C_ud objectForKey:@"last_scene"],[NSString B_setSafeString:[[NSBundle mainBundle] bundleIdentifier]]] forKey:@"last_scene"];
        
        [C_dics setValue:[C_ud objectForKey:@"logout_time"] forKey:@"logout_time"];
        
        NSMutableString *C_str = [A_JHHelp B_reqDiction:C_dics];
        NSString *C_timestr = [A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]];
        [C_dics setObject:C_timestr forKey:@"stime"];
        [C_str appendString:C_timestr];
        [C_str appendString:@"CdO23vdMos23f9l3d2*z2"];
        [C_dics setObject:[A_JHHelp B_md5:C_str] forKey:@"sign"];
        [C__infoarrs addObject: C_dics];
        
        NSLog(@"_infoarrs->%@",C__infoarrs);
        
        [A_JHHelp GetDotReport:C__infoarrs call:^(id  _Nonnull obj) {
            [C_ud setObject:[NSString stringWithFormat:@"%d",0] forKey:@"appStarNumber"];
//            [ud setObject:@"开始游戏" forKey:@"last_scene"];
            [C_ud synchronize];
        }];
    }];
}


+(void)GetDotReport:(NSMutableArray *)C_arrs call:(McBack)C_mcback{
    
    
    NSString *C_path =[NSString stringWithFormat:@"%@api/VestLogin/dotReport",C_kApiHost];
    NSLog(@"path->%@",C_path);
    NSMutableDictionary *C_alldic = [NSMutableDictionary dictionary];
    [C_alldic setObject:C_arrs forKey:@"client_info"];
//    NSLog(@"dic->%@",alldic);
    NSData *C_dataFriends = [NSJSONSerialization dataWithJSONObject:C_alldic options:NSJSONWritingPrettyPrinted error:nil];

    NSString *C_jsonString = [[NSString alloc] initWithData:C_dataFriends encoding:NSUTF8StringEncoding];
    NSLog(@"jsonString->%@",C_jsonString);

    AFURLSessionManager *C_manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    NSMutableURLRequest *C_req = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:C_path parameters:nil error:nil];

    C_req.timeoutInterval= 10;

    [C_req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    [C_req setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    [C_req setHTTPBody:[C_jsonString dataUsingEncoding:NSUTF8StringEncoding]];

    [[C_manager dataTaskWithRequest:C_req completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {

    if (!error) {

    

    if ([responseObject isKindOfClass:[NSDictionary class]]) {

        NSDictionary *dic = responseObject;
        NSLog(@"dic: %@  ---%@", dic,dic[@"msg"]);
        C_mcback(dic);
    }

    } else {

    NSLog(@"Error: %@, %@, %@", error, response, responseObject);

    }

    }] resume];
    
}

+(void)GetLogin:(McBack)C_mcback{
    
    NSString *C_username = [[NSUserDefaults standardUserDefaults] objectForKey:@"Username"];
    NSString *C_password = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    NSMutableDictionary *C_dicParame = [NSMutableDictionary dictionary];
    [C_dicParame setObject:C_username forKey:@"username"];
    [C_dicParame setObject:C_password forKey:@"password"];
    NSMutableString *C_str = [self B_reqDiction:C_dicParame];
    NSString *C_timestr = [self B_transTotimeSp:[self B_getNowTimeTimestamp]];
    [C_dicParame setObject:C_timestr forKey:@"stime"];
    [C_str appendString:C_timestr];
    [C_str appendString:@"CdO23vdMos23f9l3d2*z2"];
    NSString *C_path = [NSString stringWithFormat:@"%@/api/Game/Login?username=%@&password=%@&stime=%@&sign=%@",C_kApiHost,C_username,C_password,C_timestr,[self B_md5:C_str]];
    NSLog(@"path----%@",C_path);
    [A_AFNetworkingClient B_getWithPath:C_path withCallBack:^(id obj) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *C_dic = obj;
            NSLog(@"Login----%@",C_dic);
            if ([C_dic[@"Code"] intValue] == 20000) {
                C_mcback(C_dic[@"Data"]);
            }else{
                NSString *C_str = [NSString B_setSafeString:C_dic[@"Message"]];
                C_mcback(C_str);
            }
        }else{
            C_mcback(@"获取数据失败,请检查网络");
        }
    }];
}

+(void)PostLoginWithdic:(NSMutableDictionary *)C_dic andMcBack:(McBack)C_mcback{
    NSString *C_path =[NSString stringWithFormat:@"%@api/Game/visitorReg",C_kApiHost];
    [self setLoginParame:C_dic];
    [A_AFNetworkingClient B_postWithPath:C_path WithParams:C_dic withCallBack:^(id obj) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = obj;
            if ([dic[@"Code"] intValue] == 20000) {
                C_mcback(dic[@"Data"]);
            }else{
                NSString *C_str = [NSString B_setSafeString:dic[@"Message"]];
                C_mcback(C_str);
            }
        }else{
            C_mcback(@"获取数据失败,请检查网络");
        }
    }];
}


+ (NSString *)B_getCurrentDeviceModel{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *C_deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    
    
 if ([C_deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
 if ([C_deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
 if ([C_deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
 if ([C_deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
 if ([C_deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
 if ([C_deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
 if ([C_deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
 if ([C_deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
 if ([C_deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
 if ([C_deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
 if ([C_deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
 if ([C_deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
 if ([C_deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
 if ([C_deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
 if ([C_deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
 // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
 if ([C_deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
 if ([C_deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
 if ([C_deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
 if ([C_deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
 if ([C_deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
 if ([C_deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
 if ([C_deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
 if ([C_deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
 if ([C_deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
 if ([C_deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
 if ([C_deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
 if ([C_deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
 if ([C_deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
 if ([C_deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
 if ([C_deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
 if ([C_deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
 if ([C_deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
 if ([C_deviceModel isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
 if ([C_deviceModel isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
 if ([C_deviceModel isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
 if ([C_deviceModel isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
 if ([C_deviceModel isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";
 if ([C_deviceModel isEqualToString:@"iPhone14,4"])   return @"iPhone 13 mini";
 if ([C_deviceModel isEqualToString:@"iPhone14,5"])   return @"iPhone 13";
 if ([C_deviceModel isEqualToString:@"iPhone14,2"])   return @"iPhone 13 Pro";
 if ([C_deviceModel isEqualToString:@"iPhone14,3"])   return @"iPhone 13 Pro Max";
 if ([C_deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
 if ([C_deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
 if ([C_deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
 if ([C_deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
 if ([C_deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
 if ([C_deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
 if ([C_deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
 if ([C_deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
 if ([C_deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
 if ([C_deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
 if ([C_deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
 if ([C_deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
 if ([C_deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
 if ([C_deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
 if ([C_deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
 if ([C_deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
 if ([C_deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
 if ([C_deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
 if ([C_deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
 if ([C_deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
 if ([C_deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
 if ([C_deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
 if ([C_deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
 if ([C_deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
 if ([C_deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
 if ([C_deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
 if ([C_deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
 if ([C_deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
 if ([C_deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
 if ([C_deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
 if ([C_deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
 if ([C_deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
 if ([C_deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
 if ([C_deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
 if ([C_deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
 if ([C_deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";

 if ([C_deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
 if ([C_deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
 if ([C_deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
 if ([C_deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";

 if ([C_deviceModel isEqualToString:@"i386"])         return @"Simulator";
 if ([C_deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
     return C_deviceModel;
 }

@end
