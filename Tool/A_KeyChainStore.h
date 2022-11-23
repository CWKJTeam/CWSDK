//
//  KeyChainStore.h
//  500070
//
//  Created by 叶建辉 on 2022/7/23.
//  Copyright © 2022 egret. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface A_KeyChainStore : NSObject
+ (void)B_save:(NSString*)C_service data:(id)C_data;
+ (id)B_load:(NSString*)C_service;
+ (void)B_deleteKeyData:(NSString*)C_service;
+ (NSString *)B_getUUIDByKeyChain;
@end

NS_ASSUME_NONNULL_END
