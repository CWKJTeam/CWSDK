//
//  TYDLSessionManager.m
//  TYDLManagerDemo
//
//  Created by tany on 16/6/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "A_TYDLSessionManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import "NSURLSession+A_TYCorrectedResumeData.h"

/**
 *  下载模型
 */
@interface A_TYDLModel ()

// >>>>>>>>>>>>>>>>>>>>>>>>>>  task info
// 下载状态
@property (nonatomic, assign) A_TYDLState C_state;
// 下载任务
@property (nonatomic, strong) NSURLSessionDownloadTask *C_task;
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

/**
 *  下载进度
 */
@interface A_TYDLProgress ()
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

@interface A_TYDLSessionManager ()

// >>>>>>>>>>>>>>>>>>>>>>>>>>  file info
// 文件管理
@property (nonatomic, strong) NSFileManager *C_fileManager;
// 缓存文件目录
@property (nonatomic, strong) NSString *C_DLDirectory;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  session info
// 下载seesion会话
@property (nonatomic, strong) NSURLSession *C_session;
// 下载模型字典 key = url, value = model
@property (nonatomic, strong) NSMutableDictionary *C_DLingModelDic;
// 下载中的模型
@property (nonatomic, strong) NSMutableArray *C_waitingDLModels;
// 等待中的模型
@property (nonatomic, strong) NSMutableArray *C_DLingModels;
// 回调代理的队列
@property (strong, nonatomic) NSOperationQueue *C_queue;

@end

#define IS_IOS8ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
#define IS_IOS10ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)
#define IS_IOS12ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 12)

@implementation A_TYDLSessionManager

+ (A_TYDLSessionManager *)B_manager
{
    static id C_sharedInstance = nil;
    static dispatch_once_t C_onceToken;
    dispatch_once(&C_onceToken, ^{
        C_sharedInstance = [[self alloc] init];
    });
    return C_sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _C_backgroundConfigure = @"TYDLSessionManager.backgroundConfigure";
        _C_maxDLCount = 1;
        _C_resumeDLFIFO = YES;
        _C_isBatchDL = NO;
    }
    return self;
}

- (void)B_configureBackroundSession
{
    if (!_C_backgroundConfigure) {
        return;
    }
    [self C_session];
}

#pragma mark - getter

- (NSFileManager *)C_fileManager
{
    if (!_C_fileManager) {
        _C_fileManager = [[NSFileManager alloc]init];
    }
    return _C_fileManager;
}

- (NSURLSession *)C_session
{
    if (!_C_session) {
        if (_C_backgroundConfigure) {
            if (IS_IOS8ORLATER) {
                NSURLSessionConfiguration *configure = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_C_backgroundConfigure];
                _C_session = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:self.C_queue];
            }else{
                _C_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:_C_backgroundConfigure]delegate:self delegateQueue:self.C_queue];
            }
        }else {
            _C_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.C_queue];
        }
    }
    return _C_session;
}

- (NSOperationQueue *)C_queue
{
    if (!_C_queue) {
        _C_queue = [[NSOperationQueue alloc]init];
        _C_queue.maxConcurrentOperationCount = 1;
    }
    return _C_queue;
}

- (NSString *)C_DLDirectory
{
    if (!_C_DLDirectory) {
        _C_DLDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TYDLCache"];
        [self B_createDirectory:_C_DLDirectory];
    }
    return _C_DLDirectory;
}

- (NSMutableDictionary *)C_DLingModelDic
{
    if (!_C_DLingModelDic) {
        _C_DLingModelDic = [NSMutableDictionary dictionary];
    }
    return _C_DLingModelDic;
}

- (NSMutableArray *)C_waitingDLModels
{
    if (!_C_waitingDLModels) {
        _C_waitingDLModels = [NSMutableArray array];
    }
    return _C_waitingDLModels;
}

- (NSMutableArray *)C_DLingModels
{
    if (!_C_DLingModels) {
        _C_DLingModels = [NSMutableArray array];
    }
    return _C_DLingModels;
}

#pragma mark - downlaod

// 开始下载
- (A_TYDLModel *)B_startDLURLString:(NSString *)C_URLString toDestinationPath:(NSString *)C_destinationPath progress:(TYDLProgressBlock)C_progress state:(TYDLStateBlock)C_state
{
    // 验证下载地址
    if (!C_URLString) {
        NSLog(@"dwonloadURL can't nil");
        return nil;
    }
    
    A_TYDLModel *C_DLModel = [self B_DLingModelForURLString:C_URLString];
    
    if (!C_DLModel || ![C_DLModel.C_filePath isEqualToString:C_destinationPath]) {
        C_DLModel = [[A_TYDLModel alloc] B_initWithURLString:C_URLString filePath:C_destinationPath];
    }
    
    [self B_startWithDLModel:C_DLModel progress:C_progress state:C_state];
    
    return C_DLModel;
}

- (void)B_startWithDLModel:(A_TYDLModel *)C_DLModel progress:(TYDLProgressBlock)C_progress state:(TYDLStateBlock)C_state
{
    C_DLModel.C_progressBlock = C_progress;
    C_DLModel.C_stateBlock = C_state;
    
    [self B_startWithDLModel:C_DLModel];
}


- (void)B_startWithDLModel:(A_TYDLModel *)C_DLModel
{
    if (!C_DLModel) {
        return;
    }
    
    if (C_DLModel.C_state == C_TYDLStateReadying) {
        [self B_DLModel:C_DLModel didChangeState:C_TYDLStateReadying filePath:nil error:nil];
        return;
    }

    // 验证是否存在
    if (C_DLModel.C_task && C_DLModel.C_task.state == NSURLSessionTaskStateRunning) {
        C_DLModel.C_state = C_TYDLStateRunning;
        [self B_DLModel:C_DLModel didChangeState:C_TYDLStateRunning filePath:nil error:nil];
        return;
    }
    
    // 后台下载设置
    [self B_configirebackgroundSessionTasksWithDLModel:C_DLModel];
    
    [self B_resumeWithDLModel:C_DLModel];
}

// 恢复下载
- (void)B_resumeWithDLModel:(A_TYDLModel *)C_DLModel
{
    if (!C_DLModel) {
        return;
    }
    
    if (![self B_canResumeDownlaodModel:C_DLModel]) {
        return;
    }
    
    // 如果task 不存在 或者 取消了
    if (!C_DLModel.C_task || C_DLModel.C_task.state == NSURLSessionTaskStateCanceling) {
        
        NSData *C_resumeData = [self B_resumeDataFromFileWithDLModel:C_DLModel];
        
        if ([self B_isValideResumeData:C_resumeData]) {
            if (IS_IOS10ORLATER && !IS_IOS12ORLATER) {
                C_DLModel.C_task = [self.C_session B_DLTaskWithCorrectResumeData:C_resumeData];
            }else {
                C_DLModel.C_task = [self.C_session downloadTaskWithResumeData:C_resumeData];
            }
        }else {
            NSURLRequest *C_request = [NSURLRequest requestWithURL:[NSURL URLWithString:C_DLModel.C_DLURL]];
            C_DLModel.C_task = [self.C_session downloadTaskWithRequest:C_request];
        }
        C_DLModel.C_task.taskDescription = C_DLModel.C_DLURL;
        C_DLModel.C_DLDate = [NSDate date];
    }

    if (!C_DLModel.C_DLDate) {
        C_DLModel.C_DLDate = [NSDate date];
    }
    
    if (![self.C_DLingModelDic objectForKey:C_DLModel.C_DLURL]) {
        self.C_DLingModelDic[C_DLModel.C_DLURL] = C_DLModel;
    }
    
    [C_DLModel.C_task resume];
    
    C_DLModel.C_state = C_TYDLStateRunning;
    [self B_DLModel:C_DLModel didChangeState:C_TYDLStateRunning filePath:nil error:nil];
}

- (BOOL)B_isValideResumeData:(NSData *)C_resumeData
{
    if (!C_resumeData || C_resumeData.length == 0) {
        return NO;
    }
    return YES;
}

// 暂停下载
- (void)B_suspendWithDLModel:(A_TYDLModel *)C_DLModel
{
    if (!C_DLModel.C_manualCancle) {
        C_DLModel.C_manualCancle = YES;
        [self B_cancleWithDLModel:C_DLModel clearResumeData:NO];
    }
}

// 取消下载
- (void)B_cancleWithDLModel:(A_TYDLModel *)C_DLModel
{
    if (C_DLModel.C_state != C_TYDLStateCompleted && C_DLModel.C_state != C_TYDLStateFailed){
        [self B_cancleWithDLModel:C_DLModel clearResumeData:NO];
    }
}

// 删除下载
- (void)B_deleteFileWithDLModel:(A_TYDLModel *)C_DLModel
{
    if (!C_DLModel || !C_DLModel.C_filePath) {
        return;
    }
    
    [self B_cancleWithDLModel:C_DLModel clearResumeData:YES];
    [self B_deleteFileIfExist:C_DLModel.C_filePath];
}

- (void)B_deleteAllFileWithDLDirectory:(NSString *)C_DLDirectory
{
    if (!_C_DLDirectory) {
        _C_DLDirectory = self.C_DLDirectory;
    }
    
     for (A_TYDLModel *C_DLModel in [self.C_DLingModelDic allValues]) {
          if ([C_DLModel.C_DLDirectory isEqualToString:C_DLDirectory]) {
              [self B_cancleWithDLModel:C_DLModel clearResumeData:YES];
          }
     }
    // 删除沙盒中所有资源
    [self.C_fileManager removeItemAtPath:C_DLDirectory error:nil];
}

// 取消下载 是否删除resumeData
- (void)B_cancleWithDLModel:(A_TYDLModel *)C_DLModel clearResumeData:(BOOL)C_clearResumeData
{
    if (!C_DLModel.C_task && C_DLModel.C_state == C_TYDLStateReadying) {
        [self B_removeDLingModelForURLString:C_DLModel.C_DLURL];
        @synchronized (self) {
            [self.C_waitingDLModels removeObject:C_DLModel];
        }
        C_DLModel.C_state = C_TYDLStateNone;
        [self B_DLModel:C_DLModel didChangeState:C_TYDLStateNone filePath:nil error:nil];
        return;
    }
    if (C_clearResumeData) {
        C_DLModel.C_state = C_TYDLStateNone;
        C_DLModel.C_resumeData = nil;
        [self B_deleteFileIfExist:[self B_resumeDataPathWithDLURL:C_DLModel.C_DLURL]];
        [C_DLModel.C_task cancel];
    }else {
        [(NSURLSessionDownloadTask *)C_DLModel.C_task cancelByProducingResumeData:^(NSData *C_resumeData){
        }];
    }
}

- (void)B_willResumeNextWithDowloadModel:(A_TYDLModel *)C_DLModel
{
    if (_C_isBatchDL) {
        return;
    }
    
    @synchronized (self) {
        [self.C_DLingModels removeObject:C_DLModel];
        // 还有未下载的
        if (self.C_waitingDLModels.count > 0) {
            [self B_resumeWithDLModel:_C_resumeDLFIFO ? self.C_waitingDLModels.firstObject:self.C_waitingDLModels.lastObject];
        }
    }
}

- (BOOL)B_canResumeDownlaodModel:(A_TYDLModel *)C_DLModel
{
    if (_C_isBatchDL) {
        return YES;
    }
    
    @synchronized (self) {
        if (self.C_DLingModels.count >= _C_maxDLCount ) {
            if ([self.C_waitingDLModels indexOfObject:C_DLModel] == NSNotFound) {
                [self.C_waitingDLModels addObject:C_DLModel];
                self.C_DLingModelDic[C_DLModel.C_DLURL] = C_DLModel;
            }
            C_DLModel.C_state = C_TYDLStateReadying;
            [self B_DLModel:C_DLModel didChangeState:C_TYDLStateReadying filePath:nil error:nil];
            return NO;
        }
        
        if ([self.C_waitingDLModels indexOfObject:C_DLModel] != NSNotFound) {
            [self.C_waitingDLModels removeObject:C_DLModel];
        }
        
        if ([self.C_DLingModels indexOfObject:C_DLModel] == NSNotFound) {
            [self.C_DLingModels addObject:C_DLModel];
        }
        return YES;
    }
}

#pragma mark - configire background task

// 配置后台后台下载session
- (void)B_configirebackgroundSessionTasksWithDLModel:(A_TYDLModel *)C_DLModel
{
    if (!_C_backgroundConfigure) {
        return ;
    }
    
    NSURLSessionDownloadTask *C_task = [self B_backgroundSessionTasksWithDLModel:C_DLModel];
    if (!C_task) {
        return;
    }
    
    C_DLModel.C_task = C_task;
    if (C_task.state == NSURLSessionTaskStateRunning) {
        [C_task suspend];
    }
}

- (NSURLSessionDownloadTask *)B_backgroundSessionTasksWithDLModel:(A_TYDLModel *)C_DLModel
{
    NSArray *C_tasks = [self B_sessionDLTasks];
    for (NSURLSessionDownloadTask *C_task in C_tasks) {
        if (C_task.state == NSURLSessionTaskStateRunning || C_task.state == NSURLSessionTaskStateSuspended) {
            if ([C_DLModel.C_DLURL isEqualToString:C_task.taskDescription]) {
                return C_task;
            }
        }
    }
    return nil;
}

// 获取所以的后台下载session
- (NSArray *)B_sessionDLTasks
{
    __block NSArray *C_tasks = nil;
    dispatch_semaphore_t C_semaphore = dispatch_semaphore_create(0);
    [self.C_session getTasksWithCompletionHandler:^(NSArray *C_dataTasks, NSArray *C_uploadTasks, NSArray *C_DLTasks) {
        C_tasks = C_DLTasks;
        dispatch_semaphore_signal(C_semaphore);
    }];
    dispatch_semaphore_wait(C_semaphore, DISPATCH_TIME_FOREVER);
    return C_tasks;
}

#pragma mark - public

// 获取下载模型
- (A_TYDLModel *)B_DLingModelForURLString:(NSString *)C_URLString
{
    return [self.C_DLingModelDic objectForKey:C_URLString];
}

// 是否已经下载
- (BOOL)B_isDLCompletedWithDLModel:(A_TYDLModel *)C_DLModel
{
    return [self.C_fileManager fileExistsAtPath:C_DLModel.C_filePath];
}

// 取消所有后台
- (void)B_cancleAllBackgroundSessionTasks
{
    if (!_C_backgroundConfigure) {
        return;
    }
    
    for (NSURLSessionDownloadTask *C_task in [self B_sessionDLTasks]) {
        [C_task cancelByProducingResumeData:^(NSData * C_resumeData) {
            }];
    }
}

#pragma mark - private

- (void)B_DLModel:(A_TYDLModel *)C_DLModel didChangeState:(A_TYDLState)C_state filePath:(NSString *)C_filePath error:(NSError *)C_error
{
    if (_C_delegate && [_C_delegate respondsToSelector:@selector(B_DLModel:didChangeState:filePath:error:)]) {
        [_C_delegate B_DLModel:C_DLModel didChangeState:C_state filePath:C_filePath error:C_error];
    }
    
    if (C_DLModel.C_stateBlock) {
        C_DLModel.C_stateBlock(C_state,C_filePath,C_error);
    }
}

- (void)B_DLModel:(A_TYDLModel *)C_DLModel updateProgress:(A_TYDLProgress *)C_progress
{
    if (_C_delegate && [_C_delegate respondsToSelector:@selector(B_DLModel:didUpdateProgress:)]) {
        [_C_delegate B_DLModel:C_DLModel didUpdateProgress:C_progress];
    }
    
    if (C_DLModel.C_progressBlock) {
        C_DLModel.C_progressBlock(C_progress);
    }
}

- (void)B_removeDLingModelForURLString:(NSString *)C_URLString
{
    [self.C_DLingModelDic removeObjectForKey:C_URLString];
}

// 获取resumeData
- (NSData *)B_resumeDataFromFileWithDLModel:(A_TYDLModel *)C_DLModel
{
    if (C_DLModel.C_resumeData) {
        return C_DLModel.C_resumeData;
    }
    NSString *C_resumeDataPath = [self B_resumeDataPathWithDLURL:C_DLModel.C_DLURL];
    
    if ([_C_fileManager fileExistsAtPath:C_resumeDataPath]) {
        NSData *C_resumeData = [NSData dataWithContentsOfFile:C_resumeDataPath];
        return C_resumeData;
    }
    return nil;
}

// resumeData 路径
- (NSString *)B_resumeDataPathWithDLURL:(NSString *)C_DLURL
{
    NSString *C_resumeFileName = [[self class] B_md5:C_DLURL];
    return [self.C_DLDirectory stringByAppendingPathComponent:C_resumeFileName];
}

+ (NSString *)B_md5:(NSString *)C_str
{
    const char *C_cStr = [C_str UTF8String];
    if (C_cStr == NULL) {
        C_cStr = "";
    }
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( C_cStr, (CC_LONG)strlen(C_cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//  创建缓存目录文件
- (void)B_createDirectory:(NSString *)C_directory
{
    if (![self.C_fileManager fileExistsAtPath:C_directory]) {
        [self.C_fileManager createDirectoryAtPath:C_directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

- (void)B_moveFileAtURL:(NSURL *)C_srcURL toPath:(NSString *)C_dstPath
{
    if (!C_dstPath) {
        NSLog(@"error filePath is nil!");
        return;
    }
    NSError *C_error = nil;
    if ([self.C_fileManager fileExistsAtPath:C_dstPath] ) {
        [self.C_fileManager removeItemAtPath:C_dstPath error:&C_error];
        if (C_error) {
            NSLog(@"removeItem error %@",C_error);
        }
    }
    
    NSURL *C_dstURL = [NSURL fileURLWithPath:C_dstPath];
    [self.C_fileManager moveItemAtURL:C_srcURL toURL:C_dstURL error:&C_error];
    if (C_error){
        NSLog(@"moveItem error:%@",C_error);
    }
}

- (void)B_deleteFileIfExist:(NSString *)C_filePath
{
    if ([self.C_fileManager fileExistsAtPath:C_filePath] ) {
        NSError *C_error  = nil;
        [self.C_fileManager removeItemAtPath:C_filePath error:&C_error];
        if (C_error) {
            NSLog(@"emoveItem error %@",C_error);
        }
    }
}


#pragma mark - NSURLSessionDLDelegate

// 恢复下载
- (void)URLSession:(NSURLSession *)C_session DLTask:(NSURLSessionDownloadTask *)C_DLTask didResumeAtOffset:(int64_t)C_fileOffset expectedTotalBytes:(int64_t)C_expectedTotalBytes
{
    A_TYDLModel *C_DLModel = [self B_DLingModelForURLString:C_DLTask.taskDescription];
    
    if (!C_DLModel || C_DLModel.C_state == C_TYDLStateSuspended) {
        return;
    }
    
    C_DLModel.C_progress.C_resumeBytesWritten = C_fileOffset;
}

// 监听文件下载进度
- (void)URLSession:(NSURLSession *)C_session downloadTask:(NSURLSessionDownloadTask *)C_DLTask
      didWriteData:(int64_t)C_bytesWritten
 totalBytesWritten:(int64_t)C_totalBytesWritten
totalBytesExpectedToWrite:(int64_t)C_totalBytesExpectedToWrite
{
    A_TYDLModel *C_DLModel = [self B_DLingModelForURLString:C_DLTask.taskDescription];
    
    if (!C_DLModel || C_DLModel.C_state == C_TYDLStateSuspended) {
        return;
    }
    
    float C_progress = (double)C_totalBytesWritten/C_totalBytesExpectedToWrite;
    
    int64_t C_resumeBytesWritten = C_DLModel.C_progress.C_resumeBytesWritten;
    
    NSTimeInterval C_DLTime = -1 * [C_DLModel.C_DLDate timeIntervalSinceNow];
    float C_speed = (C_totalBytesWritten - C_resumeBytesWritten) / C_DLTime;
    
    int64_t C_remainingContentLength = C_totalBytesExpectedToWrite - C_totalBytesWritten;
    int C_remainingTime = ceilf(C_remainingContentLength / C_speed);
    
    C_DLModel.C_progress.C_bytesWritten = C_bytesWritten;
    C_DLModel.C_progress.C_totalBytesWritten = C_totalBytesWritten;
    C_DLModel.C_progress.C_totalBytesExpectedToWrite = C_totalBytesExpectedToWrite;
    C_DLModel.C_progress.C_progress = C_progress;
    C_DLModel.C_progress.C_speed = C_speed;
    C_DLModel.C_progress.C_remainingTime = C_remainingTime;
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self B_DLModel:C_DLModel updateProgress:C_DLModel.C_progress];
    });
}


// 下载成功
- (void)URLSession:(NSURLSession *)C_session downloadTask:(NSURLSessionDownloadTask *)C_DLTask
didFinishDLingToURL:(NSURL *)C_location
{
    A_TYDLModel *C_DLModel = [self B_DLingModelForURLString:C_DLTask.taskDescription];
    if (!C_DLModel && _C_backgroundSessionDLCompleteBlock) {
        NSString *C_filePath = _C_backgroundSessionDLCompleteBlock(C_DLTask.taskDescription);
        // 移动文件到下载目录
        [self B_createDirectory:C_filePath.stringByDeletingLastPathComponent];
        [self B_moveFileAtURL:C_location toPath:C_filePath];
        return;
    }
    
    if (C_location) {
        // 移动文件到下载目录
        [self B_createDirectory:C_DLModel.C_DLDirectory];
        [self B_moveFileAtURL:C_location toPath:C_DLModel.C_filePath];
    }
}

// 下载完成
- (void)URLSession:(NSURLSession *)C_session task:(NSURLSessionTask *)C_task didCompleteWithError:(NSError *)C_error
{
    A_TYDLModel *C_DLModel = [self B_DLingModelForURLString:C_task.taskDescription];
    
    if (!C_DLModel) {
        NSData *C_resumeData = C_error ? [C_error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]:nil;
        if (C_resumeData) {
            [self B_createDirectory:_C_DLDirectory];
            [C_resumeData writeToFile:[self B_resumeDataPathWithDLURL:C_task.taskDescription] atomically:YES];
        }else {
            [self B_deleteFileIfExist:[self B_resumeDataPathWithDLURL:C_task.taskDescription]];
        }
        return;
    }

    NSData *C_resumeData = nil;
    if (C_error) {
        C_resumeData = [C_error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
    }
    // 缓存resumeData
    if (C_resumeData) {
        C_DLModel.C_resumeData = C_resumeData;
        [self B_createDirectory:_C_DLDirectory];
        [C_DLModel.C_resumeData writeToFile:[self B_resumeDataPathWithDLURL:C_DLModel.C_DLURL] atomically:YES];
    }else {
        C_DLModel.C_resumeData = nil;
        [self B_deleteFileIfExist:[self B_resumeDataPathWithDLURL:C_DLModel.C_DLURL]];
    }
    
    C_DLModel.C_progress.C_resumeBytesWritten = 0;
    C_DLModel.C_task = nil;
    [self B_removeDLingModelForURLString:C_DLModel.C_DLURL];
    
    if (C_DLModel.C_manualCancle) {
        // 手动取消，当做暂停
        dispatch_async(dispatch_get_main_queue(), ^(){
            C_DLModel.C_manualCancle = NO;
            C_DLModel.C_state = C_TYDLStateSuspended;
            [self B_DLModel:C_DLModel didChangeState:C_TYDLStateSuspended filePath:nil error:nil];
            [self B_willResumeNextWithDowloadModel:C_DLModel];
        });
    }else if (C_error){
        
        if (C_DLModel.C_state == C_TYDLStateNone) {
            // 删除下载
            dispatch_async(dispatch_get_main_queue(), ^(){
                C_DLModel.C_state = C_TYDLStateNone;
                [self B_DLModel:C_DLModel didChangeState:C_TYDLStateNone filePath:nil error:C_error];
                [self B_willResumeNextWithDowloadModel:C_DLModel];
            });
        }else {
            // 下载失败
            dispatch_async(dispatch_get_main_queue(), ^(){
                C_DLModel.C_state = C_TYDLStateFailed;
                [self B_DLModel:C_DLModel didChangeState:C_TYDLStateFailed filePath:nil error:C_error];
                [self B_willResumeNextWithDowloadModel:C_DLModel];
            });
        }
    }else {
        // 下载完成
        dispatch_async(dispatch_get_main_queue(), ^(){
            C_DLModel.C_state = C_TYDLStateCompleted;
            [self B_DLModel:C_DLModel didChangeState:C_TYDLStateCompleted filePath:C_DLModel.C_filePath error:nil];
            [self B_willResumeNextWithDowloadModel:C_DLModel];
        });
    }

}

// 后台session下载完成
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    if (self.C_backgroundSessionCompletionHandler) {
        self.C_backgroundSessionCompletionHandler();
    }
}

@end
