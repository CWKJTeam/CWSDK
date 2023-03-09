//
//  JHHelp.h
//  EmptyProject
//
//  Created by 叶建辉 on 2021/12/1.
//

#import <Foundation/Foundation.h>
#import "A_Tool.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^McBack)(id obj);

@interface A_JHHelp : NSObject

+(NSString *)B_getProjBVersion;

+(BOOL)B_isDateyear:(NSInteger)C_y mon:(NSInteger)C_m day:(NSInteger)C_d;

+(UIFont *)B_getFontWithUnderSix:(float)C_underSix;
+(UIFont *)B_getboldFontWithUnderSix:(float)C_underSix;

+(NSString *)B_convertToJsonData:(NSDictionary *)C_dict;

+ (NSDictionary *)B_dictionaryWithJsonString:(NSString *)C_jsonString;

+(BOOL)B_compareVersion:(NSString *)C_v1 v2:(NSString *)C_v2;

+ (NSString *)B_getCurrentDeviceModel;

+(void)B_PostLoginAndDotReport;

+ (NSMutableString *)B_reqDiction:(NSDictionary *)C_dict;

+ (NSString *)B_getNowTimeTimestamp;

+(NSString *)B_transTotimeSp:(NSString *)C_time;

+(BOOL)B_isAccident;

+(NSInteger)B_determineNetwork;

+(void)B_DLResourcesWithUrl:(NSString *)C_url DLing:(McBack)C_back DLEnd:(McBack)C_back;

+ (NSString *) B_md5:(NSString *) C_str;

+(NSInteger)B_compareDate:(NSDate *)C_date1 andDate2:(NSDate *)C_date2;

+(void)B_GetimportantInformation:(McBack)C_back;

+(NSString*)B_generateCodeVerifier;
+ (NSString*)B_generateCodeChallenge:(NSString*)C_codeVerifier;
+ (BOOL)B_EligibleRegion;
+ (BOOL)B_isAbleSysLang;
@end

NS_ASSUME_NONNULL_END
