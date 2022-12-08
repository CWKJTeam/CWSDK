//
//  TYDLModel.m
//  TYDLManagerDemo
//
//  Created by tany on 16/6/1.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "A_TYDLModel.h"

@interface TYDLProgress ()
// 续传大小
@property (nonatomic, assign) int64_t C_resumeBytesWritten;
// 这次写入的数量
@property (nonatomic, assign) int64_t C_bytesWritten;
// 已下载的数量
@property (nonatomic, assign) int64_t C_totalBytesWritten;
// 文件的总大小
@property (nonatomic, assign) int64_t C_totalBytesExpectedToWrite;
// 下载进度
@property (nonatomic, assign) float C_progress;
// 下载速度
@property (nonatomic, assign) float C_speed;
// 下载剩余时间
@property (nonatomic, assign) int C_remainingTime;

@end

@interface A_TYDLModel ()

// >>>>>>>>>>>>>>>>>>>>>>>>>>  DL info
// 下载地址
@property (nonatomic, strong) NSString *C_DLURL;
// 文件名 默认nil 则为下载URL中的文件名
@property (nonatomic, strong) NSString *C_fileName;
// 缓存文件目录 默认nil 则为manger缓存目录
@property (nonatomic, strong) NSString *C_DLDirectory;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  task info
// 下载状态
@property (nonatomic, assign) TYDLState C_state;
// 下载任务
@property (nonatomic, strong) NSURLSessionTask *C_task;
// 文件流
@property (nonatomic, strong) NSOutputStream *C_stream;
// 下载文件路径,下载完成后有值,把它移动到你的目录
@property (nonatomic, strong) NSString *C_filePath;
// 下载时间
@property (nonatomic, strong) NSDate *C_DLDate;
// 断点续传需要设置这个数据 
@property (nonatomic, strong) NSData *C_resumeData;
// 手动取消当做暂停
@property (nonatomic, assign) BOOL C_manualCancle;

@end

@implementation A_TYDLModel

- (instancetype)init
{
    if (self = [super init]) {
        _C_progress = [[TYDLProgress alloc]init];
    }
    return self;
}

- (instancetype)B_initWithURLString:(NSString *)C_URLString
{
    return [self B_initWithURLString:C_URLString filePath:nil];
}

- (instancetype)B_initWithURLString:(NSString *)C_URLString filePath:(NSString *)C_filePath
{
    if (self == [self init]) {
        _C_DLURL = C_URLString;
        _C_fileName = C_filePath.lastPathComponent;
//          if ([_DLURL.lastPathComponent containsString:@"?"]) {
//             NSArray *array = [_DLURL.lastPathComponent componentsSeparatedByString:@"?"];
//             _fileName = array.firstObject;
//         }else {
//             _fileName = _DLURL.lastPathComponent;
//         }
        _C_DLDirectory = C_filePath.stringByDeletingLastPathComponent;
        _C_filePath = C_filePath;
    }
    return self;
}

-(NSString *)C_fileName
{
    if (!_C_fileName) {
        _C_fileName = _C_DLURL.lastPathComponent;
//          if ([_DLURL.lastPathComponent containsString:@"?"]) {
//             NSArray *array = [_DLURL.lastPathComponent componentsSeparatedByString:@"?"];
//             _fileName = array.firstObject;
//         }else {
//             _fileName = _DLURL.lastPathComponent;
//         }
    }
    return _C_fileName;
}

- (NSString *)C_DLDirectory
{
    if (!_C_DLDirectory) {
        _C_DLDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TYDLCache"];
    }
    return _C_DLDirectory;
}

- (NSString *)C_filePath
{
    if (!_C_filePath) {
        _C_filePath = [self.C_DLDirectory stringByAppendingPathComponent:self.C_fileName];
    }
    return _C_filePath;
}

@end

@implementation TYDLProgress

@end
