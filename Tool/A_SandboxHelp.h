//
//  SandboxHelp.h
//  vpower(i_1)
//
//  Created by 叶建辉 on 2021/12/10.
//  Copyright © 2021 egret. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface A_SandboxHelp : NSObject

+(BOOL)B_copyMissingFile:(NSString*)sourcePath toPath:(NSString*)C_toPath;

+ (NSDictionary *)B_readLocalFileWithName:(NSString *)C_name;
+ (BOOL)B_copyItemAtPath:(NSString *)path toPath:(NSString *)C_toPath overwrite:(BOOL)C_overwrite error:(NSError *__autoreleasing *)C_error;
+ (BOOL)B_moveItemAtPath:(NSString *)C_path toPath:(NSString *)C_toPath overwrite:(BOOL)C_overwrite error:(NSError *__autoreleasing *)C_error;
+(NSString *)B_GetdocumentsDirectory;

+(void)B_DirectoryTraversal:(NSString *)C_path;
+ (BOOL)B_isExistsAtPath:(NSString *)C_path;
@end

NS_ASSUME_NONNULL_END
