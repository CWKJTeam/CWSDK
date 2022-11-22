//
//  TYDownLoadDataManager.h
//  TYDownloadManagerDemo
//
//  Created by tany on 16/6/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A_TYDownloadModel.h"
#import "A_TYDownloadDelegate.h"

/**
 *  下载管理类 封装NSURLSessionDataTask
 */
@interface A_TYDownLoadDataManager : NSObject <NSURLSessionDataDelegate>

// 下载代理
@property (nonatomic,weak) id<A_TYDownloadDelegate> delegate;

// 等待中的模型 只读
@property (nonatomic, strong,readonly) NSMutableArray *C_waitingDownloadModels;

// 下载中的模型 只读
@property (nonatomic, strong,readonly) NSMutableArray *C_downloadingModels;

// 最大下载数
@property (nonatomic, assign) NSInteger C_maxDownloadCount;

// 等待下载队列 先进先出 默认YES， 当NO时，先进后出
@property (nonatomic, assign) BOOL C_resumeDownloadFIFO;

// 全部并发 默认NO, 当YES时，忽略maxDownloadCount
@property (nonatomic, assign) BOOL C_isBatchDownload;

// 单例
+ (A_TYDownLoadDataManager *)manager;

// 开始下载
- (A_TYDownloadModel *)startDownloadURLString:(NSString *)URLString toDestinationPath:(NSString *)destinationPath progress:(TYDownloadProgressBlock)progress state:(TYDownloadStateBlock)state;

// 开始下载
- (void)startWithDownloadModel:(A_TYDownloadModel *)downloadModel progress:(TYDownloadProgressBlock)progress state:(TYDownloadStateBlock)state;

// 开始下载
- (void)startWithDownloadModel:(A_TYDownloadModel *)downloadModel;

// 恢复下载（除非确定对这个model进行了suspend，否则使用start）
- (void)resumeWithDownloadModel:(A_TYDownloadModel *)downloadModel;

// 暂停下载
- (void)suspendWithDownloadModel:(A_TYDownloadModel *)downloadModel;

// 取消下载
- (void)cancleWithDownloadModel:(A_TYDownloadModel *)downloadModel;

// 删除下载
- (void)deleteFileWithDownloadModel:(A_TYDownloadModel *)downloadModel;

// 删除下载
- (void)deleteAllFileWithDownloadDirectory:(NSString *)downloadDirectory;

// 获取正在下载模型
- (A_TYDownloadModel *)downLoadingModelForURLString:(NSString *)URLString;

// 获取本地下载模型的进度
- (TYDownloadProgress *)progessWithDownloadModel:(A_TYDownloadModel *)downloadModel;

// 是否已经下载
- (BOOL)isDownloadCompletedWithDownloadModel:(A_TYDownloadModel *)downloadModel;

@end
