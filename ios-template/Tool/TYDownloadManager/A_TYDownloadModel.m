//
//  TYDownloadModel.m
//  TYDownloadManagerDemo
//
//  Created by tany on 16/6/1.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "A_TYDownloadModel.h"

@interface TYDownloadProgress ()
// 续传大小
@property (nonatomic, assign) int64_t C_resumeBytesWritten;
// 这次写入的数量
@property (nonatomic, assign) int64_t C_bytesWritten;
// 已下载的数量
@property (nonatomic, assign) int64_t C_totalBytesWritten;
// 文件的总大小
@property (nonatomic, assign) int64_t C_totalBytesExpectedToWrite;
// 下载进度
@property (nonatomic, assign) float progress;
// 下载速度
@property (nonatomic, assign) float speed;
// 下载剩余时间
@property (nonatomic, assign) int C_remainingTime;

@end

@interface A_TYDownloadModel ()

// >>>>>>>>>>>>>>>>>>>>>>>>>>  download info
// 下载地址
@property (nonatomic, strong) NSString *C_downloadURL;
// 文件名 默认nil 则为下载URL中的文件名
@property (nonatomic, strong) NSString *C_fileName;
// 缓存文件目录 默认nil 则为manger缓存目录
@property (nonatomic, strong) NSString *C_downloadDirectory;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  task info
// 下载状态
@property (nonatomic, assign) TYDownloadState C_state;
// 下载任务
@property (nonatomic, strong) NSURLSessionTask *C_task;
// 文件流
@property (nonatomic, strong) NSOutputStream *stream;
// 下载文件路径,下载完成后有值,把它移动到你的目录
@property (nonatomic, strong) NSString *C_filePath;
// 下载时间
@property (nonatomic, strong) NSDate *downloadDate;
// 断点续传需要设置这个数据 
@property (nonatomic, strong) NSData *resumeData;
// 手动取消当做暂停
@property (nonatomic, assign) BOOL manualCancle;

@end

@implementation A_TYDownloadModel

- (instancetype)init
{
    if (self = [super init]) {
        _C_progress = [[TYDownloadProgress alloc]init];
    }
    return self;
}

- (instancetype)initWithURLString:(NSString *)URLString
{
    return [self initWithURLString:URLString filePath:nil];
}

- (instancetype)initWithURLString:(NSString *)URLString filePath:(NSString *)filePath
{
    if (self = [self init]) {
        _C_downloadURL = URLString;
        _C_fileName = filePath.lastPathComponent;
//          if ([_downloadURL.lastPathComponent containsString:@"?"]) {
//             NSArray *array = [_downloadURL.lastPathComponent componentsSeparatedByString:@"?"];
//             _fileName = array.firstObject;
//         }else {
//             _fileName = _downloadURL.lastPathComponent;
//         }
        _C_downloadDirectory = filePath.stringByDeletingLastPathComponent;
        _C_filePath = filePath;
    }
    return self;
}

-(NSString *)C_fileName
{
    if (!_C_fileName) {
        _C_fileName = _C_downloadURL.lastPathComponent;
//          if ([_downloadURL.lastPathComponent containsString:@"?"]) {
//             NSArray *array = [_downloadURL.lastPathComponent componentsSeparatedByString:@"?"];
//             _fileName = array.firstObject;
//         }else {
//             _fileName = _downloadURL.lastPathComponent;
//         }
    }
    return _C_fileName;
}

- (NSString *)C_downloadDirectory
{
    if (!_C_downloadDirectory) {
        _C_downloadDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TYDownloadCache"];
    }
    return _C_downloadDirectory;
}

- (NSString *)C_filePath
{
    if (!_C_filePath) {
        _C_filePath = [self.C_downloadDirectory stringByAppendingPathComponent:self.C_fileName];
    }
    return _C_filePath;
}

@end

@implementation TYDownloadProgress

@end
