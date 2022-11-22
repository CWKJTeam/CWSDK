//
//  TYDownloadSessionManager.m
//  TYDownloadManagerDemo
//
//  Created by tany on 16/6/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "A_TYDownloadSessionManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import "NSURLSession+TYCorrectedResumeData.h"

/**
 *  下载模型
 */
@interface A_TYDownloadModel ()

// >>>>>>>>>>>>>>>>>>>>>>>>>>  task info
// 下载状态
@property (nonatomic, assign) TYDownloadState C_state;
// 下载任务
@property (nonatomic, strong) NSURLSessionDownloadTask *C_task;
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

/**
 *  下载进度
 */
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

@interface A_TYDownloadSessionManager ()

// >>>>>>>>>>>>>>>>>>>>>>>>>>  file info
// 文件管理
@property (nonatomic, strong) NSFileManager *fileManager;
// 缓存文件目录
@property (nonatomic, strong) NSString *downloadDirectory;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  session info
// 下载seesion会话
@property (nonatomic, strong) NSURLSession *session;
// 下载模型字典 key = url, value = model
@property (nonatomic, strong) NSMutableDictionary *downloadingModelDic;
// 下载中的模型
@property (nonatomic, strong) NSMutableArray *C_waitingDownloadModels;
// 等待中的模型
@property (nonatomic, strong) NSMutableArray *C_downloadingModels;
// 回调代理的队列
@property (strong, nonatomic) NSOperationQueue *queue;

@end

#define IS_IOS8ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)
#define IS_IOS10ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10)
#define IS_IOS12ORLATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 12)

@implementation A_TYDownloadSessionManager

+ (A_TYDownloadSessionManager *)manager
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _C_backgroundConfigure = @"TYDownloadSessionManager.backgroundConfigure";
        _C_maxDownloadCount = 1;
        _C_resumeDownloadFIFO = YES;
        _C_isBatchDownload = NO;
    }
    return self;
}

- (void)configureBackroundSession
{
    if (!_C_backgroundConfigure) {
        return;
    }
    [self session];
}

#pragma mark - getter

- (NSFileManager *)fileManager
{
    if (!_fileManager) {
        _fileManager = [[NSFileManager alloc]init];
    }
    return _fileManager;
}

- (NSURLSession *)session
{
    if (!_session) {
        if (_C_backgroundConfigure) {
            if (IS_IOS8ORLATER) {
                NSURLSessionConfiguration *configure = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:_C_backgroundConfigure];
                _session = [NSURLSession sessionWithConfiguration:configure delegate:self delegateQueue:self.queue];
            }else{
                _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:_C_backgroundConfigure]delegate:self delegateQueue:self.queue];
            }
        }else {
            _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.queue];
        }
    }
    return _session;
}

- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return _queue;
}

- (NSString *)downloadDirectory
{
    if (!_downloadDirectory) {
        _downloadDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TYDownloadCache"];
        [self createDirectory:_downloadDirectory];
    }
    return _downloadDirectory;
}

- (NSMutableDictionary *)downloadingModelDic
{
    if (!_downloadingModelDic) {
        _downloadingModelDic = [NSMutableDictionary dictionary];
    }
    return _downloadingModelDic;
}

- (NSMutableArray *)C_waitingDownloadModels
{
    if (!_C_waitingDownloadModels) {
        _C_waitingDownloadModels = [NSMutableArray array];
    }
    return _C_waitingDownloadModels;
}

- (NSMutableArray *)C_downloadingModels
{
    if (!_C_downloadingModels) {
        _C_downloadingModels = [NSMutableArray array];
    }
    return _C_downloadingModels;
}

#pragma mark - downlaod

// 开始下载
- (A_TYDownloadModel *)startDownloadURLString:(NSString *)URLString toDestinationPath:(NSString *)destinationPath progress:(TYDownloadProgressBlock)progress state:(TYDownloadStateBlock)state
{
    // 验证下载地址
    if (!URLString) {
        NSLog(@"dwonloadURL can't nil");
        return nil;
    }
    
    A_TYDownloadModel *downloadModel = [self downLoadingModelForURLString:URLString];
    
    if (!downloadModel || ![downloadModel.C_filePath isEqualToString:destinationPath]) {
        downloadModel = [[A_TYDownloadModel alloc]initWithURLString:URLString filePath:destinationPath];
    }
    
    [self startWithDownloadModel:downloadModel progress:progress state:state];
    
    return downloadModel;
}

- (void)startWithDownloadModel:(A_TYDownloadModel *)downloadModel progress:(TYDownloadProgressBlock)progress state:(TYDownloadStateBlock)state
{
    downloadModel.progressBlock = progress;
    downloadModel.stateBlock = state;
    
    [self startWithDownloadModel:downloadModel];
}


- (void)startWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    if (!downloadModel) {
        return;
    }
    
    if (downloadModel.C_state == TYDownloadStateReadying) {
        [self downloadModel:downloadModel didChangeState:TYDownloadStateReadying filePath:nil error:nil];
        return;
    }

    // 验证是否存在
    if (downloadModel.C_task && downloadModel.C_task.state == NSURLSessionTaskStateRunning) {
        downloadModel.C_state = TYDownloadStateRunning;
        [self downloadModel:downloadModel didChangeState:TYDownloadStateRunning filePath:nil error:nil];
        return;
    }
    
    // 后台下载设置
    [self configirebackgroundSessionTasksWithDownloadModel:downloadModel];
    
    [self resumeWithDownloadModel:downloadModel];
}

// 恢复下载
- (void)resumeWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    if (!downloadModel) {
        return;
    }
    
    if (![self canResumeDownlaodModel:downloadModel]) {
        return;
    }
    
    // 如果task 不存在 或者 取消了
    if (!downloadModel.C_task || downloadModel.C_task.state == NSURLSessionTaskStateCanceling) {
        
        NSData *resumeData = [self resumeDataFromFileWithDownloadModel:downloadModel];
        
        if ([self isValideResumeData:resumeData]) {
            if (IS_IOS10ORLATER && !IS_IOS12ORLATER) {
                downloadModel.C_task = [self.session downloadTaskWithCorrectResumeData:resumeData];
            }else {
                 downloadModel.C_task = [self.session downloadTaskWithResumeData:resumeData];
            }
        }else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadModel.C_downloadURL]];
            downloadModel.C_task = [self.session downloadTaskWithRequest:request];
        }
        downloadModel.C_task.taskDescription = downloadModel.C_downloadURL;
        downloadModel.downloadDate = [NSDate date];
    }

    if (!downloadModel.downloadDate) {
        downloadModel.downloadDate = [NSDate date];
    }
    
    if (![self.downloadingModelDic objectForKey:downloadModel.C_downloadURL]) {
        self.downloadingModelDic[downloadModel.C_downloadURL] = downloadModel;
    }
    
    [downloadModel.C_task resume];
    
    downloadModel.C_state = TYDownloadStateRunning;
    [self downloadModel:downloadModel didChangeState:TYDownloadStateRunning filePath:nil error:nil];
}

- (BOOL)isValideResumeData:(NSData *)resumeData
{
    if (!resumeData || resumeData.length == 0) {
        return NO;
    }
    return YES;
}

// 暂停下载
- (void)suspendWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    if (!downloadModel.manualCancle) {
        downloadModel.manualCancle = YES;
        [self cancleWithDownloadModel:downloadModel clearResumeData:NO];
    }
}

// 取消下载
- (void)cancleWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    if (downloadModel.C_state != TYDownloadStateCompleted && downloadModel.C_state != TYDownloadStateFailed){
        [self cancleWithDownloadModel:downloadModel clearResumeData:NO];
    }
}

// 删除下载
- (void)deleteFileWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    if (!downloadModel || !downloadModel.C_filePath) {
        return;
    }
    
    [self cancleWithDownloadModel:downloadModel clearResumeData:YES];
    [self deleteFileIfExist:downloadModel.C_filePath];
}

- (void)deleteAllFileWithDownloadDirectory:(NSString *)downloadDirectory
{
    if (!downloadDirectory) {
        downloadDirectory = self.downloadDirectory;
    }
    
     for (A_TYDownloadModel *downloadModel in [self.downloadingModelDic allValues]) {
          if ([downloadModel.C_downloadDirectory isEqualToString:downloadDirectory]) {
              [self cancleWithDownloadModel:downloadModel clearResumeData:YES];
          }
     }
    // 删除沙盒中所有资源
    [self.fileManager removeItemAtPath:downloadDirectory error:nil];
}

// 取消下载 是否删除resumeData
- (void)cancleWithDownloadModel:(A_TYDownloadModel *)downloadModel clearResumeData:(BOOL)clearResumeData
{
    if (!downloadModel.C_task && downloadModel.C_state == TYDownloadStateReadying) {
        [self removeDownLoadingModelForURLString:downloadModel.C_downloadURL];
        @synchronized (self) {
            [self.C_waitingDownloadModels removeObject:downloadModel];
        }
        downloadModel.C_state = TYDownloadStateNone;
        [self downloadModel:downloadModel didChangeState:TYDownloadStateNone filePath:nil error:nil];
        return;
    }
    if (clearResumeData) {
        downloadModel.C_state = TYDownloadStateNone;
        downloadModel.resumeData = nil;
        [self deleteFileIfExist:[self resumeDataPathWithDownloadURL:downloadModel.C_downloadURL]];
        [downloadModel.C_task cancel];
    }else {
        [(NSURLSessionDownloadTask *)downloadModel.C_task cancelByProducingResumeData:^(NSData *resumeData){
        }];
    }
}

- (void)willResumeNextWithDowloadModel:(A_TYDownloadModel *)downloadModel
{
    if (_C_isBatchDownload) {
        return;
    }
    
    @synchronized (self) {
        [self.C_downloadingModels removeObject:downloadModel];
        // 还有未下载的
        if (self.C_waitingDownloadModels.count > 0) {
            [self resumeWithDownloadModel:_C_resumeDownloadFIFO ? self.C_waitingDownloadModels.firstObject:self.C_waitingDownloadModels.lastObject];
        }
    }
}

- (BOOL)canResumeDownlaodModel:(A_TYDownloadModel *)downloadModel
{
    if (_C_isBatchDownload) {
        return YES;
    }
    
    @synchronized (self) {
        if (self.C_downloadingModels.count >= _C_maxDownloadCount ) {
            if ([self.C_waitingDownloadModels indexOfObject:downloadModel] == NSNotFound) {
                [self.C_waitingDownloadModels addObject:downloadModel];
                self.downloadingModelDic[downloadModel.C_downloadURL] = downloadModel;
            }
            downloadModel.C_state = TYDownloadStateReadying;
            [self downloadModel:downloadModel didChangeState:TYDownloadStateReadying filePath:nil error:nil];
            return NO;
        }
        
        if ([self.C_waitingDownloadModels indexOfObject:downloadModel] != NSNotFound) {
            [self.C_waitingDownloadModels removeObject:downloadModel];
        }
        
        if ([self.C_downloadingModels indexOfObject:downloadModel] == NSNotFound) {
            [self.C_downloadingModels addObject:downloadModel];
        }
        return YES;
    }
}

#pragma mark - configire background task

// 配置后台后台下载session
- (void)configirebackgroundSessionTasksWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    if (!_C_backgroundConfigure) {
        return ;
    }
    
    NSURLSessionDownloadTask *task = [self backgroundSessionTasksWithDownloadModel:downloadModel];
    if (!task) {
        return;
    }
    
    downloadModel.C_task = task;
    if (task.state == NSURLSessionTaskStateRunning) {
        [task suspend];
    }
}

- (NSURLSessionDownloadTask *)backgroundSessionTasksWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    NSArray *tasks = [self sessionDownloadTasks];
    for (NSURLSessionDownloadTask *task in tasks) {
        if (task.state == NSURLSessionTaskStateRunning || task.state == NSURLSessionTaskStateSuspended) {
            if ([downloadModel.C_downloadURL isEqualToString:task.taskDescription]) {
                return task;
            }
        }
    }
    return nil;
}

// 获取所以的后台下载session
- (NSArray *)sessionDownloadTasks
{
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        tasks = downloadTasks;
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return tasks;
}

#pragma mark - public

// 获取下载模型
- (A_TYDownloadModel *)downLoadingModelForURLString:(NSString *)URLString
{
    return [self.downloadingModelDic objectForKey:URLString];
}

// 是否已经下载
- (BOOL)isDownloadCompletedWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    return [self.fileManager fileExistsAtPath:downloadModel.C_filePath];
}

// 取消所有后台
- (void)cancleAllBackgroundSessionTasks
{
    if (!_C_backgroundConfigure) {
        return;
    }
    
    for (NSURLSessionDownloadTask *task in [self sessionDownloadTasks]) {
        [task cancelByProducingResumeData:^(NSData * resumeData) {
            }];
    }
}

#pragma mark - private

- (void)downloadModel:(A_TYDownloadModel *)downloadModel didChangeState:(TYDownloadState)state filePath:(NSString *)filePath error:(NSError *)error
{
    if (_delegate && [_delegate respondsToSelector:@selector(downloadModel:didChangeState:filePath:error:)]) {
        [_delegate downloadModel:downloadModel didChangeState:state filePath:filePath error:error];
    }
    
    if (downloadModel.stateBlock) {
        downloadModel.stateBlock(state,filePath,error);
    }
}

- (void)downloadModel:(A_TYDownloadModel *)downloadModel updateProgress:(TYDownloadProgress *)progress
{
    if (_delegate && [_delegate respondsToSelector:@selector(downloadModel:didUpdateProgress:)]) {
        [_delegate downloadModel:downloadModel didUpdateProgress:progress];
    }
    
    if (downloadModel.progressBlock) {
        downloadModel.progressBlock(progress);
    }
}

- (void)removeDownLoadingModelForURLString:(NSString *)URLString
{
    [self.downloadingModelDic removeObjectForKey:URLString];
}

// 获取resumeData
- (NSData *)resumeDataFromFileWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    if (downloadModel.resumeData) {
        return downloadModel.resumeData;
    }
    NSString *resumeDataPath = [self resumeDataPathWithDownloadURL:downloadModel.C_downloadURL];
    
    if ([_fileManager fileExistsAtPath:resumeDataPath]) {
        NSData *resumeData = [NSData dataWithContentsOfFile:resumeDataPath];
        return resumeData;
    }
    return nil;
}

// resumeData 路径
- (NSString *)resumeDataPathWithDownloadURL:(NSString *)downloadURL
{
    NSString *resumeFileName = [[self class] md5:downloadURL];
    return [self.downloadDirectory stringByAppendingPathComponent:resumeFileName];
}

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    if (cStr == NULL) {
        cStr = "";
    }
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//  创建缓存目录文件
- (void)createDirectory:(NSString *)directory
{
    if (![self.fileManager fileExistsAtPath:directory]) {
        [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

- (void)moveFileAtURL:(NSURL *)srcURL toPath:(NSString *)dstPath
{
    if (!dstPath) {
        NSLog(@"error filePath is nil!");
        return;
    }
    NSError *error = nil;
    if ([self.fileManager fileExistsAtPath:dstPath] ) {
        [self.fileManager removeItemAtPath:dstPath error:&error];
        if (error) {
            NSLog(@"removeItem error %@",error);
        }
    }
    
    NSURL *dstURL = [NSURL fileURLWithPath:dstPath];
    [self.fileManager moveItemAtURL:srcURL toURL:dstURL error:&error];
    if (error){
        NSLog(@"moveItem error:%@",error);
    }
}

- (void)deleteFileIfExist:(NSString *)filePath
{
    if ([self.fileManager fileExistsAtPath:filePath] ) {
        NSError *error  = nil;
        [self.fileManager removeItemAtPath:filePath error:&error];
        if (error) {
            NSLog(@"emoveItem error %@",error);
        }
    }
}


#pragma mark - NSURLSessionDownloadDelegate

// 恢复下载
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    A_TYDownloadModel *downloadModel = [self downLoadingModelForURLString:downloadTask.taskDescription];
    
    if (!downloadModel || downloadModel.C_state == TYDownloadStateSuspended) {
        return;
    }
    
    downloadModel.C_progress.C_resumeBytesWritten = fileOffset;
}

// 监听文件下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    A_TYDownloadModel *downloadModel = [self downLoadingModelForURLString:downloadTask.taskDescription];
    
    if (!downloadModel || downloadModel.C_state == TYDownloadStateSuspended) {
        return;
    }
    
    float progress = (double)totalBytesWritten/totalBytesExpectedToWrite;
    
    int64_t resumeBytesWritten = downloadModel.C_progress.C_resumeBytesWritten;
    
    NSTimeInterval downloadTime = -1 * [downloadModel.downloadDate timeIntervalSinceNow];
    float speed = (totalBytesWritten - resumeBytesWritten) / downloadTime;
    
    int64_t remainingContentLength = totalBytesExpectedToWrite - totalBytesWritten;
    int remainingTime = ceilf(remainingContentLength / speed);
    
    downloadModel.C_progress.C_bytesWritten = bytesWritten;
    downloadModel.C_progress.C_totalBytesWritten = totalBytesWritten;
    downloadModel.C_progress.C_totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    downloadModel.C_progress.progress = progress;
    downloadModel.C_progress.speed = speed;
    downloadModel.C_progress.C_remainingTime = remainingTime;
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self downloadModel:downloadModel updateProgress:downloadModel.C_progress];
    });
}


// 下载成功
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    A_TYDownloadModel *downloadModel = [self downLoadingModelForURLString:downloadTask.taskDescription];
    if (!downloadModel && _backgroundSessionDownloadCompleteBlock) {
        NSString *filePath = _backgroundSessionDownloadCompleteBlock(downloadTask.taskDescription);
        // 移动文件到下载目录
        [self createDirectory:filePath.stringByDeletingLastPathComponent];
        [self moveFileAtURL:location toPath:filePath];
        return;
    }
    
    if (location) {
        // 移动文件到下载目录
        [self createDirectory:downloadModel.C_downloadDirectory];
        [self moveFileAtURL:location toPath:downloadModel.C_filePath];
    }
}

// 下载完成
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    A_TYDownloadModel *downloadModel = [self downLoadingModelForURLString:task.taskDescription];
    
    if (!downloadModel) {
        NSData *resumeData = error ? [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]:nil;
        if (resumeData) {
            [self createDirectory:_downloadDirectory];
            [resumeData writeToFile:[self resumeDataPathWithDownloadURL:task.taskDescription] atomically:YES];
        }else {
            [self deleteFileIfExist:[self resumeDataPathWithDownloadURL:task.taskDescription]];
        }
        return;
    }

    NSData *resumeData = nil;
    if (error) {
        resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
    }
    // 缓存resumeData
    if (resumeData) {
        downloadModel.resumeData = resumeData;
        [self createDirectory:_downloadDirectory];
        [downloadModel.resumeData writeToFile:[self resumeDataPathWithDownloadURL:downloadModel.C_downloadURL] atomically:YES];
    }else {
        downloadModel.resumeData = nil;
        [self deleteFileIfExist:[self resumeDataPathWithDownloadURL:downloadModel.C_downloadURL]];
    }
    
    downloadModel.C_progress.C_resumeBytesWritten = 0;
    downloadModel.C_task = nil;
    [self removeDownLoadingModelForURLString:downloadModel.C_downloadURL];
    
    if (downloadModel.manualCancle) {
        // 手动取消，当做暂停
        dispatch_async(dispatch_get_main_queue(), ^(){
            downloadModel.manualCancle = NO;
            downloadModel.C_state = TYDownloadStateSuspended;
            [self downloadModel:downloadModel didChangeState:TYDownloadStateSuspended filePath:nil error:nil];
            [self willResumeNextWithDowloadModel:downloadModel];
        });
    }else if (error){
        
        if (downloadModel.C_state == TYDownloadStateNone) {
            // 删除下载
            dispatch_async(dispatch_get_main_queue(), ^(){
                downloadModel.C_state = TYDownloadStateNone;
                [self downloadModel:downloadModel didChangeState:TYDownloadStateNone filePath:nil error:error];
                [self willResumeNextWithDowloadModel:downloadModel];
            });
        }else {
            // 下载失败
            dispatch_async(dispatch_get_main_queue(), ^(){
                downloadModel.C_state = TYDownloadStateFailed;
                [self downloadModel:downloadModel didChangeState:TYDownloadStateFailed filePath:nil error:error];
                [self willResumeNextWithDowloadModel:downloadModel];
            });
        }
    }else {
        // 下载完成
        dispatch_async(dispatch_get_main_queue(), ^(){
            downloadModel.C_state = TYDownloadStateCompleted;
            [self downloadModel:downloadModel didChangeState:TYDownloadStateCompleted filePath:downloadModel.C_filePath error:nil];
            [self willResumeNextWithDowloadModel:downloadModel];
        });
    }

}

// 后台session下载完成
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    if (self.backgroundSessionCompletionHandler) {
        self.backgroundSessionCompletionHandler();
    }
}

@end
