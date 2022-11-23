//
//  TYDownLoadDataManager.m
//  TYDownloadManagerDemo
//
//  Created by tany on 16/6/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "A_TYDownLoadDataManager.h"

/**
 *  下载模型
 */
@interface A_TYDownloadModel ()

// >>>>>>>>>>>>>>>>>>>>>>>>>>  task info
// 下载状态
@property (nonatomic, assign) TYDownloadState C_state;
// 下载任务
@property (nonatomic, strong) NSURLSessionDataTask *C_task;
// 文件流
@property (nonatomic, strong) NSOutputStream *stream;
// 下载文件路径
@property (nonatomic, strong) NSString *C_filePath;
// 下载时间
@property (nonatomic, strong) NSDate *downloadDate;
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


@interface A_TYDownLoadDataManager ()

// >>>>>>>>>>>>>>>>>>>>>>>>>>  file info
// 文件管理
@property (nonatomic, strong) NSFileManager *fileManager;
// 缓存文件目录
@property (nonatomic, strong) NSString *downloadDirectory;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  session info
// 下载seesion会话
@property (nonatomic, strong) NSURLSession *session;
// 下载模型字典 key = url
@property (nonatomic, strong) NSMutableDictionary *downloadingModelDic;
// 下载中的模型
@property (nonatomic, strong) NSMutableArray *C_waitingDownloadModels;
// 等待中的模型
@property (nonatomic, strong) NSMutableArray *C_downloadingModels;
// 回调代理的队列
@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation A_TYDownLoadDataManager

#pragma mark - getter

+ (A_TYDownLoadDataManager *)manager
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
        _C_maxDownloadCount = 1;
        _C_resumeDownloadFIFO = YES;
        _C_isBatchDownload = NO;
    }
    return self;
}

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
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.queue];
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

// 下载文件信息plist路径
- (NSString *)fileSizePathWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    return [downloadModel.C_downloadDirectory stringByAppendingPathComponent:@"downloadsFileSize.plist"];
}

// 下载model字典
- (NSMutableDictionary *)downloadingModelDic
{
    if (!_downloadingModelDic) {
        _downloadingModelDic = [NSMutableDictionary dictionary];
    }
    return _downloadingModelDic;
}

// 等待下载model队列
- (NSMutableArray *)C_waitingDownloadModels
{
    if (!_C_waitingDownloadModels) {
        _C_waitingDownloadModels = [NSMutableArray array];
    }
    return _C_waitingDownloadModels;
}

// 正在下载model队列
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
    
    // 验证是否已经下载文件
    if ([self isDownloadCompletedWithDownloadModel:downloadModel]) {
        downloadModel.C_state = TYDownloadStateCompleted;
        [self downloadModel:downloadModel didChangeState:TYDownloadStateCompleted filePath:downloadModel.C_filePath error:nil];
        return;
    }
    
    // 验证是否存在
    if (downloadModel.C_task && downloadModel.C_task.state == NSURLSessionTaskStateRunning) {
        downloadModel.C_state = TYDownloadStateRunning;
        [self downloadModel:downloadModel didChangeState:TYDownloadStateRunning filePath:nil error:nil];
        return;
    }
    
    [self resumeWithDownloadModel:downloadModel];
}

// 自动下载下一个等待队列任务
- (void)willResumeNextWithDowloadModel:(A_TYDownloadModel *)downloadModel
{
    if (_C_isBatchDownload) {
        return;
    }
    
    @synchronized (self) {
//        [self.downloadingModels removeObject:downloadModel];
        // 还有未下载的
        if (self.C_waitingDownloadModels.count > 0) {
            [self resumeWithDownloadModel:_C_resumeDownloadFIFO ? self.C_waitingDownloadModels.firstObject:self.C_waitingDownloadModels.lastObject];
        }
    }
}

// 是否开启下载等待队列任务
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
        
//        if ([self.downloadingModels indexOfObject:downloadModel] == NSNotFound) {
//            [self.downloadingModels addObject:downloadModel];
//        }
        return YES;
    }
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
        NSString *URLString = downloadModel.C_downloadURL;
        
        // 创建请求
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URLString]];
        
        // 设置请求头
        NSString *range = [NSString stringWithFormat:@"bytes=%zd-", [self fileSizeWithDownloadModel:downloadModel]];
        [request setValue:range forHTTPHeaderField:@"Range"];
        
        // 创建流
        downloadModel.stream = [NSOutputStream outputStreamToFileAtPath:downloadModel.C_filePath append:YES];
        
        downloadModel.downloadDate = [NSDate date];
        self.downloadingModelDic[downloadModel.C_downloadURL] = downloadModel;
        // 创建一个Data任务
        downloadModel.C_task = [self.session dataTaskWithRequest:request];
        downloadModel.C_task.taskDescription = URLString;
    }
    
    [downloadModel.C_task resume];
    
    downloadModel.C_state = TYDownloadStateRunning;
    [self downloadModel:downloadModel didChangeState:TYDownloadStateRunning filePath:nil error:nil];
}

// 暂停下载
- (void)suspendWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    if (!downloadModel.manualCancle) {
        downloadModel.manualCancle = YES;
        [downloadModel.C_task cancel];
    }
}

// 取消下载
- (void)cancleWithDownloadModel:(A_TYDownloadModel *)downloadModel
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
    
    if (downloadModel.C_state != TYDownloadStateCompleted && downloadModel.C_state != TYDownloadStateFailed){
        [downloadModel.C_task cancel];
    }
}

#pragma mark - delete file

- (void)deleteFileWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    if (!downloadModel || !downloadModel.C_filePath) {
        return;
    }
    
    // 文件是否存在
    if ([self.fileManager fileExistsAtPath:downloadModel.C_filePath]) {
        
        // 删除任务
        downloadModel.C_task.taskDescription = nil;
        [downloadModel.C_task cancel];
        downloadModel.C_task = nil;
        
        // 删除流
        if (downloadModel.stream.streamStatus > NSStreamStatusNotOpen && downloadModel.stream.streamStatus < NSStreamStatusClosed) {
            [downloadModel.stream close];
        }
        downloadModel.stream = nil;
        // 删除沙盒中的资源
        NSError *error = nil;
        [self.fileManager removeItemAtPath:downloadModel.C_filePath error:&error];
        if (error) {
            NSLog(@"delete file error %@",error);
        }
        
        [self removeDownLoadingModelForURLString:downloadModel.C_downloadURL];
        // 删除资源总长度
        if ([self.fileManager fileExistsAtPath:[self fileSizePathWithDownloadModel:downloadModel]]) {
            @synchronized (self) {
                NSMutableDictionary *dict = [self fileSizePlistWithDownloadModel:downloadModel];
                [dict removeObjectForKey:downloadModel.C_downloadURL];
                [dict writeToFile:[self fileSizePathWithDownloadModel:downloadModel] atomically:YES];
            }
        }
    }
}

- (void)deleteAllFileWithDownloadDirectory:(NSString *)downloadDirectory
{
    if (!downloadDirectory) {
        downloadDirectory = self.downloadDirectory;
    }
    if ([self.fileManager fileExistsAtPath:downloadDirectory]) {
        
        // 删除任务
        for (A_TYDownloadModel *downloadModel in [self.downloadingModelDic allValues]) {
            if ([downloadModel.C_downloadDirectory isEqualToString:downloadDirectory]) {
                // 删除任务
                downloadModel.C_task.taskDescription = nil;
                [downloadModel.C_task cancel];
                downloadModel.C_task = nil;
                
                // 删除流
                if (downloadModel.stream.streamStatus > NSStreamStatusNotOpen && downloadModel.stream.streamStatus < NSStreamStatusClosed) {
                    [downloadModel.stream close];
                }
                downloadModel.stream = nil;
            }
        }
        // 删除沙盒中所有资源
        [self.fileManager removeItemAtPath:downloadDirectory error:nil];
    }
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
    long long fileSize = [self fileSizeInCachePlistWithDownloadModel:downloadModel];
    if (fileSize > 0 && fileSize == [self fileSizeWithDownloadModel:downloadModel]) {
        return YES;
    }
    return NO;
}

// 当前下载进度
- (TYDownloadProgress *)progessWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    TYDownloadProgress *progress = [[TYDownloadProgress alloc]init];
    progress.C_totalBytesExpectedToWrite = [self fileSizeInCachePlistWithDownloadModel:downloadModel];
    progress.C_totalBytesWritten = MIN([self fileSizeWithDownloadModel:downloadModel], progress.C_totalBytesExpectedToWrite);
    progress.progress = progress.C_totalBytesExpectedToWrite > 0 ? 1.0*progress.C_totalBytesWritten/progress.C_totalBytesExpectedToWrite : 0;
    
    return progress;
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

//  创建缓存目录文件
- (void)createDirectory:(NSString *)directory
{
    if (![self.fileManager fileExistsAtPath:directory]) {
        [self.fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

// 获取文件大小
- (long long)fileSizeWithDownloadModel:(A_TYDownloadModel *)downloadModel{
    NSString *filePath = downloadModel.C_filePath;
    if (![self.fileManager fileExistsAtPath:filePath]) return 0;
    return [[self.fileManager attributesOfItemAtPath:filePath error:nil] fileSize];
}

// 获取plist保存文件大小
- (long long)fileSizeInCachePlistWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    NSDictionary *downloadsFileSizePlist = [NSDictionary dictionaryWithContentsOfFile:[self fileSizePathWithDownloadModel:downloadModel]];
    return [downloadsFileSizePlist[downloadModel.C_downloadURL] longLongValue];
}

// 获取plist文件内容
- (NSMutableDictionary *)fileSizePlistWithDownloadModel:(A_TYDownloadModel *)downloadModel
{
    NSMutableDictionary *downloadsFileSizePlist = [NSMutableDictionary dictionaryWithContentsOfFile:[self fileSizePathWithDownloadModel:downloadModel]];
    if (!downloadsFileSizePlist) {
        downloadsFileSizePlist = [NSMutableDictionary dictionary];
    }
    return downloadsFileSizePlist;
}

- (void)removeDownLoadingModelForURLString:(NSString *)URLString
{
    [self.downloadingModelDic removeObjectForKey:URLString];
}

#pragma mark - NSURLSessionDelegate

/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    A_TYDownloadModel *downloadModel = [self downLoadingModelForURLString:dataTask.taskDescription];
    if (!downloadModel) {
        return;
    }
    
    // 创建目录
    [self createDirectory:_downloadDirectory];
    [self createDirectory:downloadModel.C_downloadDirectory];
    
    // 打开流
    [downloadModel.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    long long totalBytesWritten =  [self fileSizeWithDownloadModel:downloadModel];
    long long totalBytesExpectedToWrite = totalBytesWritten + dataTask.countOfBytesExpectedToReceive;
    
    downloadModel.C_progress.C_resumeBytesWritten = totalBytesWritten;
    downloadModel.C_progress.C_totalBytesWritten = totalBytesWritten;
    downloadModel.C_progress.C_totalBytesExpectedToWrite = totalBytesExpectedToWrite;
    
    // 存储总长度
    @synchronized (self) {
        NSMutableDictionary *dic = [self fileSizePlistWithDownloadModel:downloadModel];
        dic[downloadModel.C_downloadURL] = @(totalBytesExpectedToWrite);
        [dic writeToFile:[self fileSizePathWithDownloadModel:downloadModel] atomically:YES];
    }
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    A_TYDownloadModel *downloadModel = [self downLoadingModelForURLString:dataTask.taskDescription];
    if (!downloadModel || downloadModel.C_state == TYDownloadStateSuspended) {
        return;
    }
    // 写入数据
    [downloadModel.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    downloadModel.C_progress.C_bytesWritten = data.length;
    downloadModel.C_progress.C_totalBytesWritten += downloadModel.C_progress.C_bytesWritten;
    downloadModel.C_progress.progress  = MIN(1.0, 1.0*downloadModel.C_progress.C_totalBytesWritten/downloadModel.C_progress.C_totalBytesExpectedToWrite);
    
    // 时间
    NSTimeInterval downloadTime = -1 * [downloadModel.downloadDate timeIntervalSinceNow];
    downloadModel.C_progress.speed = (downloadModel.C_progress.C_totalBytesWritten - downloadModel.C_progress.C_resumeBytesWritten) / downloadTime;
    
    int64_t remainingContentLength = downloadModel.C_progress.C_totalBytesExpectedToWrite - downloadModel.C_progress.C_totalBytesWritten;
    downloadModel.C_progress.C_remainingTime = ceilf(remainingContentLength / downloadModel.C_progress.speed);
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self downloadModel:downloadModel updateProgress:downloadModel.C_progress];
    });
}

/**
 * 请求完毕（成功|失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    A_TYDownloadModel *downloadModel = [self downLoadingModelForURLString:task.taskDescription];
    
    if (!downloadModel) {
        return;
    }
    
    // 关闭流
    [downloadModel.stream close];
    downloadModel.stream = nil;
    downloadModel.C_task = nil;
    
    [self removeDownLoadingModelForURLString:downloadModel.C_downloadURL];

    if (downloadModel.manualCancle) {
        // 暂停下载
        dispatch_async(dispatch_get_main_queue(), ^(){
            downloadModel.manualCancle = NO;
            downloadModel.C_state = TYDownloadStateSuspended;
            [self downloadModel:downloadModel didChangeState:TYDownloadStateSuspended filePath:nil error:nil];
            [self willResumeNextWithDowloadModel:downloadModel];
        });
    }else if (error){
        // 下载失败
        dispatch_async(dispatch_get_main_queue(), ^(){
            downloadModel.C_state = TYDownloadStateFailed;
            [self downloadModel:downloadModel didChangeState:TYDownloadStateFailed filePath:nil error:error];
            [self willResumeNextWithDowloadModel:downloadModel];
        });
    }else if ([self isDownloadCompletedWithDownloadModel:downloadModel]) {
        // 下载完成
        dispatch_async(dispatch_get_main_queue(), ^(){
            downloadModel.C_state = TYDownloadStateCompleted;
            [self downloadModel:downloadModel didChangeState:TYDownloadStateCompleted filePath:downloadModel.C_filePath error:nil];
            [self willResumeNextWithDowloadModel:downloadModel];
        });
    }else {
        // 下载完成
         dispatch_async(dispatch_get_main_queue(), ^(){
             downloadModel.C_state = TYDownloadStateCompleted;
             [self downloadModel:downloadModel didChangeState:TYDownloadStateCompleted filePath:downloadModel.C_filePath error:nil];
             [self willResumeNextWithDowloadModel:downloadModel];
         });
    }
}

@end
