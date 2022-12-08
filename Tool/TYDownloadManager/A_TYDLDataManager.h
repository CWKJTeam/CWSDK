//
//  TYDLDataManager.h
//  TYDLManagerDemo
//
//  Created by tany on 16/6/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A_TYDLModel.h"
#import "A_TYDLDelegate.h"

/**
 *  下载管理类 封装NSURLSessionDataTask
 */
@interface A_TYDLDataManager : NSObject <NSURLSessionDataDelegate>

// 下载代理
@property (nonatomic,weak) id<A_TYDLDelegate> C_delegate;

// 等待中的模型 只读
@property (nonatomic, strong,readonly) NSMutableArray *C_waitingDLModels;

// 下载中的模型 只读
@property (nonatomic, strong,readonly) NSMutableArray *C_DLingModels;

// 最大下载数
@property (nonatomic, assign) NSInteger C_maxDLCount;

// 等待下载队列 先进先出 默认YES， 当NO时，先进后出
@property (nonatomic, assign) BOOL C_resumeDLFIFO;

// 全部并发 默认NO, 当YES时，忽略maxDLCount
@property (nonatomic, assign) BOOL C_isBatchDL;

// 单例
+ (A_TYDLDataManager *)B_manager;

// 开始下载
- (A_TYDLModel *)B_startDLURLString:(NSString *)C_URLString toDestinationPath:(NSString *)C_destinationPath progress:(TYDLProgressBlock)C_progress state:(TYDLStateBlock)C_state;

// 开始下载
- (void)B_startWithDLModel:(A_TYDLModel *)C_DLModel progress:(TYDLProgressBlock)C_progress state:(TYDLStateBlock)C_state;

// 开始下载
- (void)B_startWithDLModel:(A_TYDLModel *)C_DLModel;

// 恢复下载（除非确定对这个model进行了suspend，否则使用start）
- (void)B_resumeWithDLModel:(A_TYDLModel *)C_DLModel;

// 暂停下载
- (void)B_suspendWithDLModel:(A_TYDLModel *)C_DLModel;

// 取消下载
- (void)B_cancleWithDLModel:(A_TYDLModel *)C_DLModel;

// 删除下载
- (void)B_deleteFileWithDLModel:(A_TYDLModel *)C_DLModel;

// 删除下载
- (void)B_deleteAllFileWithDLDirectory:(NSString *)C_DLDirectory;

// 获取正在下载模型
- (A_TYDLModel *)B_DLingModelForURLString:(NSString *)C_URLString;

// 获取本地下载模型的进度
- (TYDLProgress *)B_progessWithDLModel:(A_TYDLModel *)C_DLModel;

// 是否已经下载
- (BOOL)B_isDLCompletedWithDLModel:(A_TYDLModel *)C_DLModel;

@end
