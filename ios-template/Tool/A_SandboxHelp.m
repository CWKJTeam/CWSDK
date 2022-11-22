//
//  SandboxHelp.m
//  vpower(i_1)
//
//  Created by 叶建辉 on 2021/12/10.
//  Copyright © 2021 egret. All rights reserved.
//

#import "A_SandboxHelp.h"

@implementation A_SandboxHelp

+(BOOL)B_copyMissingFile:(NSString*)C_sourcePath toPath:(NSString*)C_toPath{
    BOOL C_retVal = YES;
    NSString * C_finalLocation = [C_toPath stringByAppendingPathComponent:[C_sourcePath lastPathComponent]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:C_finalLocation]){
        C_retVal = [[NSFileManager defaultManager] copyItemAtPath:C_sourcePath toPath:C_finalLocation error:NULL];
    }
    return C_retVal;
}

+ (NSDictionary *)B_readLocalFileWithName:(NSString *)C_name
{
    // 获取文件路径
    NSString *C_path = [[NSBundle mainBundle] pathForResource:C_name ofType:@"json"];
    // 将文件数据化
    
    NSData *C_data = [[NSData alloc] initWithContentsOfFile:C_path];
    if (!C_data) {
        return @{};
    }
    return [NSJSONSerialization JSONObjectWithData:C_data
                                           options:kNilOptions
                                             error:nil];
}

+ (BOOL)B_copyItemAtPath:(NSString *)C_path toPath:(NSString *)C_toPath overwrite:(BOOL)C_overwrite error:(NSError *__autoreleasing *)C_error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![self B_isExistsAtPath:C_path]) {
        NSLog(@"copyItemAtPath--->>%@",C_path);
//        [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
        return NO;
    }
    //获得目标文件的上级目录
    NSString *C_toDirPath = [self B_directoryAtPath:C_toPath];
    if (![self B_isExistsAtPath:C_toDirPath]) {
        // 创建复制路径
        if (![self B_createDirectoryAtPath:C_toDirPath error:C_error]) {
            return NO;
        }
    }
    // 如果覆盖，那么先删掉原文件
    if (C_overwrite) {
        if ([self B_isExistsAtPath:C_toPath]) {
            [self B_removeItemAtPath:C_toPath error:C_error];
        }
    }
    // 复制文件，如果不覆盖且文件已存在则会复制失败
    BOOL C_isSuccess = [[NSFileManager defaultManager] copyItemAtPath:C_path toPath:C_toPath error:C_error];
    
    return C_isSuccess;
}


+ (BOOL)B_moveItemAtPath:(NSString *)C_path toPath:(NSString *)C_toPath overwrite:(BOOL)C_overwrite error:(NSError *__autoreleasing *)C_error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![self B_isExistsAtPath:C_path]) {
        [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", C_path];
        return NO;
    }
    //获得目标文件的上级目录
    NSString *C_toDirPath = [self B_directoryAtPath:C_toPath];
    if (![self B_isExistsAtPath:C_toDirPath]) {
        // 创建移动路径
        if (![self B_createDirectoryAtPath:C_toDirPath error:C_error]) {
            return NO;
        }
    }
    // 判断目标路径文件是否存在
    if ([self B_isExistsAtPath:C_toPath]) {
        //如果覆盖，删除目标路径文件
        if (C_overwrite) {
            //删掉目标路径文件
            [self B_removeItemAtPath:C_toPath error:C_error];
        }else {
           //删掉被移动文件
            [self B_removeItemAtPath:C_path error:C_error];
            return YES;
        }
    }
    
    // 移动文件，当要移动到的文件路径文件存在，会移动失败
    BOOL C_isSuccess = [[NSFileManager defaultManager] moveItemAtPath:C_path toPath:C_toPath error:C_error];
    
    return C_isSuccess;
}

+ (BOOL)B_isExistsAtPath:(NSString *)C_path {
    return [[NSFileManager defaultManager] fileExistsAtPath:C_path];
}


+ (BOOL)B_createDirectoryAtPath:(NSString *)C_path error:(NSError *__autoreleasing *)C_error {
    NSFileManager *C_manager = [NSFileManager defaultManager];
    /* createDirectoryAtPath:withIntermediateDirectories:attributes:error:
     * 参数1：创建的文件夹的路径
     * 参数2：是否创建媒介的布尔值，一般为YES
     * 参数3: 属性，没有就置为nil
     * 参数4: 错误信息
    */
    BOOL C_isSuccess = [C_manager createDirectoryAtPath:C_path withIntermediateDirectories:YES attributes:nil error:C_error];
    return C_isSuccess;
}

+ (NSString *)B_directoryAtPath:(NSString *)C_path {
    return [C_path stringByDeletingLastPathComponent];
}


+ (BOOL)B_removeItemAtPath:(NSString *)C_path error:(NSError *__autoreleasing *)C_error {
    return [[NSFileManager defaultManager] removeItemAtPath:C_path error:C_error];
}

+(NSString *)B_GetdocumentsDirectory{
    NSArray*C_pathsss =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    return [C_pathsss objectAtIndex:0];
}

+(void)B_DirectoryTraversal:(NSString *)C_path{
    NSFileManager *C_fm;
    NSDirectoryEnumerator *C_dirEnum;
    NSArray *C_dirArray;
    C_fm = [NSFileManager defaultManager];
//1.获取当前目录下的所有文件夹、文件、子文件夹、子文件夹的文件
//path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];//获取当前的工作目录的路径
    //遍历这个目录的第一种方法：（深度遍历，会递归枚举它的内容）
    C_dirEnum = [C_fm enumeratorAtPath:C_path];
    NSLog(@"1.Contents of %@",C_path);
    while ((C_path = [C_dirEnum nextObject]) != nil)
    {
        NSLog(@"path----->>>%@",C_path);
    }
//遍历目录的另一种方法：（不递归枚举文件夹中的的内容，只展示当前目录下的文件夹）
//    dirArray = [fm directoryContentsAtPath: path];
//    for (NSString *str in dirArray) {
//        NSLog(@"path->%@",str);
//    }
    
}

@end
