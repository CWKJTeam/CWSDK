//
//  GameDal.h
//  vpower(i_1)
//
//  Created by 叶建辉 on 2021/12/8.
//  Copyright © 2021 egret. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^GameBack)(id obj);

typedef void (^AfBack)(BOOL success,id obj);

@interface A_GameDal : NSObject
//第一步
+(void)B_GetHostHead:(GameBack)C_back;

//第二步
+(void)B_GetAppConfigWithPath:(NSString *)C_path andBack:(GameBack)C_back;
//第三步
+(void)B_GetLastInfoWithPath:(NSString *)C_path andBack:(GameBack)C_back;


+(void)B_PostAppReport:(NSString *)C_path andParams:(NSDictionary *)C_dic andBack:(AfBack)back;

+(void)B_PostAppLoginReport:(NSString *)C_path andParams:(NSDictionary *)C_dic andBack:(AfBack)C_back;

@end

NS_ASSUME_NONNULL_END
