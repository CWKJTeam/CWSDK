//
//  TYDLModel.h
//  TYDLManagerDemo
//
//  Created by tany on 16/6/1.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>

// 下载状态
typedef NS_ENUM(NSUInteger, A_TYDLState) {
    C_TYDLStateNone,        // 未下载 或 下载删除了
    C_TYDLStateReadying,    // 等待下载
    C_TYDLStateRunning,     // 正在下载
    C_TYDLStateSuspended,   // 下载暂停
    C_TYDLStateCompleted,   // 下载完成
    C_TYDLStateFailed       // 下载失败
};

@class A_TYDLProgress;
@class A_TYDLModel;

// 进度更新block
typedef void (^TYDLProgressBlock)(A_TYDLProgress *progress);
// 状态更新block
typedef void (^TYDLStateBlock)(A_TYDLState state,NSString *filePath, NSError *error);

/**
 *  下载模型
 */
@interface A_TYDLModel : NSObject

// >>>>>>>>>>>>>>>>>>>>>>>>>>  DL info
// 下载地址
@property (nonatomic, strong, readonly) NSString *C_DLURL;
// 文件名 默认nil 则为下载URL中的文件名
@property (nonatomic, strong, readonly) NSString *C_fileName;
// 缓存文件目录 默认nil 则为manger缓存目录
@property (nonatomic, strong, readonly) NSString *C_DLDirectory;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  task info
// 下载状态
@property (nonatomic, assign, readonly) A_TYDLState C_state;
// 下载任务
@property (nonatomic, strong, readonly) NSURLSessionTask *C_task;
// 文件流
@property (nonatomic, strong, readonly) NSOutputStream *C_stream;
// 下载进度
@property (nonatomic, strong ,readonly) A_TYDLProgress *C_progress;
// 下载路径 如果设置了DLDirectory，文件下载完成后会移动到这个目录，否则，在manager默认cache目录里
@property (nonatomic, strong, readonly) NSString *C_filePath;

@property (nonatomic, assign) NSInteger C_DLType;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  DL block
// 下载进度更新block
@property (nonatomic, copy) TYDLProgressBlock C_progressBlock;
// 下载状态更新block
@property (nonatomic, copy) TYDLStateBlock C_stateBlock;


- (instancetype)B_initWithURLString:(NSString *)C_URLString;
/**
 *  初始化方法
 *
 *  @param C_URLString 下载地址
 *  @param C_filePath  缓存地址 当为nil 默认缓存到cache
 */
- (instancetype)B_initWithURLString:(NSString *)C_URLString filePath:(NSString *)C_filePath;

@end

/**
 *  下载进度
 */
@interface A_TYDLProgress : NSObject

// 续传大小
@property (nonatomic, assign, readonly) int64_t C_resumeBytesWritten;
// 这次写入的数量
@property (nonatomic, assign, readonly) int64_t C_bytesWritten;
// 已下载的数量
@property (nonatomic, assign, readonly) int64_t C_totalBytesWritten;
// 文件的总大小
@property (nonatomic, assign, readonly) int64_t C_totalBytesExpectedToWrite;
// 下载进度
@property (nonatomic, assign, readonly) float C_progress;
// 下载速度
@property (nonatomic, assign, readonly) float C_speed;
// 下载剩余时间
@property (nonatomic, assign, readonly) int C_remainingTime;


@end
