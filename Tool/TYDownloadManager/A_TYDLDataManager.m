//
//  TYDLDataManager.m
//  TYDLManagerDemo
//
//  Created by tany on 16/6/12.
//  Copyright © 2016年 tany. All rights reserved.
//

#import "A_TYDLDataManager.h"

/**
 *  下载模型
 */
@interface A_TYDLModel ()

// >>>>>>>>>>>>>>>>>>>>>>>>>>  task info
// 下载状态
@property (nonatomic, assign) TYDLState C_state;
// 下载任务
@property (nonatomic, strong) NSURLSessionDataTask *C_task;
// 文件流
@property (nonatomic, strong) NSOutputStream *C_stream;
// 下载文件路径
@property (nonatomic, strong) NSString *C_filePath;
// 下载时间
@property (nonatomic, strong) NSDate *C_DLDate;
// 手动取消当做暂停
@property (nonatomic, assign) BOOL C_manualCancle;

@end

/**
 *  下载进度
 */
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


@interface A_TYDLDataManager ()

// >>>>>>>>>>>>>>>>>>>>>>>>>>  file info
// 文件管理
@property (nonatomic, strong) NSFileManager *C_fileManager;
// 缓存文件目录
@property (nonatomic, strong) NSString *C_DLDirectory;

// >>>>>>>>>>>>>>>>>>>>>>>>>>  session info
// 下载seesion会话
@property (nonatomic, strong) NSURLSession *C_session;
// 下载模型字典 key = url
@property (nonatomic, strong) NSMutableDictionary *C_DLingModelDic;
// 下载中的模型
@property (nonatomic, strong) NSMutableArray *C_waitingDLModels;
// 等待中的模型
@property (nonatomic, strong) NSMutableArray *C_DLingModels;
// 回调代理的队列
@property (strong, nonatomic) NSOperationQueue *C_queue;

@end

@implementation A_TYDLDataManager

#pragma mark - getter

+ (A_TYDLDataManager *)B_manager
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
        _C_maxDLCount = 1;
        _C_resumeDLFIFO = YES;
        _C_isBatchDL = NO;
    }
    return self;
}

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
        _C_session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:self.C_queue];
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

// 下载文件信息plist路径
- (NSString *)B_fileSizePathWithDLModel:(A_TYDLModel *)C_DLModel
{
    return [C_DLModel.C_DLDirectory stringByAppendingPathComponent:@"DLsFileSize.plist"];
}

// 下载model字典
- (NSMutableDictionary *)C_DLingModelDic
{
    if (!_C_DLingModelDic) {
        _C_DLingModelDic = [NSMutableDictionary dictionary];
    }
    return _C_DLingModelDic;
}

// 等待下载model队列
- (NSMutableArray *)C_waitingDLModels
{
    if (!_C_waitingDLModels) {
        _C_waitingDLModels = [NSMutableArray array];
    }
    return _C_waitingDLModels;
}

// 正在下载model队列
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
    
    // 验证是否已经下载文件
    if ([self B_isDLCompletedWithDLModel:C_DLModel]) {
        C_DLModel.C_state = C_TYDLStateCompleted;
        [self B_DLModel:C_DLModel didChangeState:C_TYDLStateCompleted filePath:C_DLModel.C_filePath error:nil];
        return;
    }
    
    // 验证是否存在
    if (C_DLModel.C_task && C_DLModel.C_task.state == NSURLSessionTaskStateRunning) {
        C_DLModel.C_state = C_TYDLStateRunning;
        [self B_DLModel:C_DLModel didChangeState:C_TYDLStateRunning filePath:nil error:nil];
        return;
    }
    
    [self B_resumeWithDLModel:C_DLModel];
}

// 自动下载下一个等待队列任务
- (void)B_willResumeNextWithDowloadModel:(A_TYDLModel *)C_DLModel
{
    if (_C_isBatchDL) {
        return;
    }
    
    @synchronized (self) {
//        [self.DLingModels removeObject:DLModel];
        // 还有未下载的
        if (self.C_waitingDLModels.count > 0) {
            [self B_resumeWithDLModel:_C_resumeDLFIFO ? self.C_waitingDLModels.firstObject:self.C_waitingDLModels.lastObject];
        }
    }
}

// 是否开启下载等待队列任务
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
        
//        if ([self.DLingModels indexOfObject:DLModel] == NSNotFound) {
//            [self.DLingModels addObject:DLModel];
//        }
        return YES;
    }
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
        NSString *C_URLString = C_DLModel.C_DLURL;
        
        // 创建请求
        NSMutableURLRequest *C_request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:C_URLString]];
        
        // 设置请求头
        NSString *C_range = [NSString stringWithFormat:@"bytes=%zd-", [self B_fileSizeWithDLModel:C_DLModel]];
        [C_request setValue:C_range forHTTPHeaderField:@"Range"];
        
        // 创建流
        C_DLModel.C_stream = [NSOutputStream outputStreamToFileAtPath:C_DLModel.C_filePath append:YES];
        
        C_DLModel.C_DLDate = [NSDate date];
        self.C_DLingModelDic[C_DLModel.C_DLURL] = C_DLModel;
        // 创建一个Data任务
        C_DLModel.C_task = [self.C_session dataTaskWithRequest:C_request];
        C_DLModel.C_task.taskDescription = C_URLString;
    }
    
    [C_DLModel.C_task resume];
    
    C_DLModel.C_state = C_TYDLStateRunning;
    [self B_DLModel:C_DLModel didChangeState:C_TYDLStateRunning filePath:nil error:nil];
}

// 暂停下载
- (void)B_suspendWithDLModel:(A_TYDLModel *)C_DLModel
{
    if (!C_DLModel.C_manualCancle) {
        C_DLModel.C_manualCancle = YES;
        [C_DLModel.C_task cancel];
    }
}

// 取消下载
- (void)B_cancleWithDLModel:(A_TYDLModel *)C_DLModel
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
    
    if (C_DLModel.C_state != C_TYDLStateCompleted && C_DLModel.C_state != C_TYDLStateFailed){
        [C_DLModel.C_task cancel];
    }
}

#pragma mark - delete file

- (void)B_deleteFileWithDLModel:(A_TYDLModel *)C_DLModel
{
    if (!C_DLModel || !C_DLModel.C_filePath) {
        return;
    }
    
    // 文件是否存在
    if ([self.C_fileManager fileExistsAtPath:C_DLModel.C_filePath]) {
        
        // 删除任务
        C_DLModel.C_task.taskDescription = nil;
        [C_DLModel.C_task cancel];
        C_DLModel.C_task = nil;
        
        // 删除流
        if (C_DLModel.C_stream.streamStatus > NSStreamStatusNotOpen && C_DLModel.C_stream.streamStatus < NSStreamStatusClosed) {
            [C_DLModel.C_stream close];
        }
        C_DLModel.C_stream = nil;
        // 删除沙盒中的资源
        NSError *C_error = nil;
        [self.C_fileManager removeItemAtPath:C_DLModel.C_filePath error:&C_error];
        if (C_error) {
            NSLog(@"delete file error %@",C_error);
        }
        
        [self B_removeDLingModelForURLString:C_DLModel.C_DLURL];
        // 删除资源总长度
        if ([self.C_fileManager fileExistsAtPath:[self B_fileSizePathWithDLModel:C_DLModel]]) {
            @synchronized (self) {
                NSMutableDictionary *C_dict = [self B_fileSizePlistWithDLModel:C_DLModel];
                [C_dict removeObjectForKey:C_DLModel.C_DLURL];
                [C_dict writeToFile:[self B_fileSizePathWithDLModel:C_DLModel] atomically:YES];
            }
        }
    }
}

- (void)B_deleteAllFileWithDLDirectory:(NSString *)C_DLDirectory
{
    if (!C_DLDirectory) {
        C_DLDirectory = self.C_DLDirectory;
    }
    if ([self.C_fileManager fileExistsAtPath:C_DLDirectory]) {
        
        // 删除任务
        for (A_TYDLModel *C_DLModel in [self.C_DLingModelDic allValues]) {
            if ([C_DLModel.C_DLDirectory isEqualToString:C_DLDirectory]) {
                // 删除任务
                C_DLModel.C_task.taskDescription = nil;
                [C_DLModel.C_task cancel];
                C_DLModel.C_task = nil;
                
                // 删除流
                if (C_DLModel.C_stream.streamStatus > NSStreamStatusNotOpen && C_DLModel.C_stream.streamStatus < NSStreamStatusClosed) {
                    [C_DLModel.C_stream close];
                }
                C_DLModel.C_stream = nil;
            }
        }
        // 删除沙盒中所有资源
        [self.C_fileManager removeItemAtPath:C_DLDirectory error:nil];
    }
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
    long long C_fileSize = [self B_fileSizeInCachePlistWithDLModel:C_DLModel];
    if (C_fileSize > 0 && C_fileSize == [self B_fileSizeWithDLModel:C_DLModel]) {
        return YES;
    }
    return NO;
}

// 当前下载进度
- (TYDLProgress *)B_progessWithDLModel:(A_TYDLModel *)C_DLModel
{
    TYDLProgress *C_progress = [[TYDLProgress alloc]init];
    C_progress.C_totalBytesExpectedToWrite = [self B_fileSizeInCachePlistWithDLModel:C_DLModel];
    C_progress.C_totalBytesWritten = MIN([self B_fileSizeWithDLModel:C_DLModel], C_progress.C_totalBytesExpectedToWrite);
    C_progress.C_progress = C_progress.C_totalBytesExpectedToWrite > 0 ? 1.0*C_progress.C_totalBytesWritten/C_progress.C_totalBytesExpectedToWrite : 0;
    
    return C_progress;
}

#pragma mark - private

- (void)B_DLModel:(A_TYDLModel *)C_DLModel didChangeState:(TYDLState)C_state filePath:(NSString *)C_filePath error:(NSError *)C_error
{
    if (_C_delegate && [_C_delegate respondsToSelector:@selector(B_DLModel:didChangeState:filePath:error:)]) {
        [_C_delegate B_DLModel:C_DLModel didChangeState:C_state filePath:C_filePath error:C_error];
    }
    
    if (C_DLModel.C_stateBlock) {
        C_DLModel.C_stateBlock(C_state,C_filePath,C_error);
    }
}

- (void)B_DLModel:(A_TYDLModel *)C_DLModel updateProgress:(TYDLProgress *)C_progress
{
    if (_C_delegate && [_C_delegate respondsToSelector:@selector(B_DLModel:didUpdateProgress:)]) {
        [_C_delegate B_DLModel:C_DLModel didUpdateProgress:C_progress];
    }
    
    if (C_DLModel.C_progressBlock) {
        C_DLModel.C_progressBlock(C_progress);
    }
}

//  创建缓存目录文件
- (void)B_createDirectory:(NSString *)C_directory
{
    if (![self.C_fileManager fileExistsAtPath:C_directory]) {
        [self.C_fileManager createDirectoryAtPath:C_directory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

// 获取文件大小
- (long long)B_fileSizeWithDLModel:(A_TYDLModel *)C_DLModel{
    NSString *C_filePath = C_DLModel.C_filePath;
    if (![self.C_fileManager fileExistsAtPath:C_filePath]) return 0;
    return [[self.C_fileManager attributesOfItemAtPath:C_filePath error:nil] fileSize];
}

// 获取plist保存文件大小
- (long long)B_fileSizeInCachePlistWithDLModel:(A_TYDLModel *)C_DLModel
{
    NSDictionary *C_DLsFileSizePlist = [NSDictionary dictionaryWithContentsOfFile:[self B_fileSizePathWithDLModel:C_DLModel]];
    return [C_DLsFileSizePlist[C_DLModel.C_DLURL] longLongValue];
}

// 获取plist文件内容
- (NSMutableDictionary *)B_fileSizePlistWithDLModel:(A_TYDLModel *)C_DLModel
{
    NSMutableDictionary *C_DLsFileSizePlist = [NSMutableDictionary dictionaryWithContentsOfFile:[self B_fileSizePathWithDLModel:C_DLModel]];
    if (!C_DLsFileSizePlist) {
        C_DLsFileSizePlist = [NSMutableDictionary dictionary];
    }
    return C_DLsFileSizePlist;
}

- (void)B_removeDLingModelForURLString:(NSString *)C_URLString
{
    [self.C_DLingModelDic removeObjectForKey:C_URLString];
}

#pragma mark - NSURLSessionDelegate

/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)C_session dataTask:(NSURLSessionDataTask *)C_dataTask didReceiveResponse:(NSHTTPURLResponse *)C_response completionHandler:(void (^)(NSURLSessionResponseDisposition))C_completionHandler
{
    
    A_TYDLModel *C_DLModel = [self B_DLingModelForURLString:C_dataTask.taskDescription];
    if (!C_DLModel) {
        return;
    }
    
    // 创建目录
    [self B_createDirectory:_C_DLDirectory];
    [self B_createDirectory:C_DLModel.C_DLDirectory];
    
    // 打开流
    [C_DLModel.C_stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    long long C_totalBytesWritten =  [self B_fileSizeWithDLModel:C_DLModel];
    long long C_totalBytesExpectedToWrite = C_totalBytesWritten + C_dataTask.countOfBytesExpectedToReceive;
    
    C_DLModel.C_progress.C_resumeBytesWritten = C_totalBytesWritten;
    C_DLModel.C_progress.C_totalBytesWritten = C_totalBytesWritten;
    C_DLModel.C_progress.C_totalBytesExpectedToWrite = C_totalBytesExpectedToWrite;
    
    // 存储总长度
    @synchronized (self) {
        NSMutableDictionary *C_dic = [self B_fileSizePlistWithDLModel:C_DLModel];
        C_dic[C_DLModel.C_DLURL] = @(C_totalBytesExpectedToWrite);
        [C_dic writeToFile:[self B_fileSizePathWithDLModel:C_DLModel] atomically:YES];
    }
    
    // 接收这个请求，允许接收服务器的数据
    C_completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)C_session dataTask:(NSURLSessionDataTask *)C_dataTask didReceiveData:(NSData *)C_data
{
    A_TYDLModel *C_DLModel = [self B_DLingModelForURLString:C_dataTask.taskDescription];
    if (!C_DLModel || C_DLModel.C_state == C_TYDLStateSuspended) {
        return;
    }
    // 写入数据
    [C_DLModel.C_stream write:C_data.bytes maxLength:C_data.length];
    
    // 下载进度
    C_DLModel.C_progress.C_bytesWritten = C_data.length;
    C_DLModel.C_progress.C_totalBytesWritten += C_DLModel.C_progress.C_bytesWritten;
    C_DLModel.C_progress.C_progress  = MIN(1.0, 1.0*C_DLModel.C_progress.C_totalBytesWritten/C_DLModel.C_progress.C_totalBytesExpectedToWrite);
    
    // 时间
    NSTimeInterval C_DLTime = -1 * [C_DLModel.C_DLDate timeIntervalSinceNow];
    C_DLModel.C_progress.C_speed = (C_DLModel.C_progress.C_totalBytesWritten - C_DLModel.C_progress.C_resumeBytesWritten) / C_DLTime;
    
    int64_t C_remainingContentLength = C_DLModel.C_progress.C_totalBytesExpectedToWrite - C_DLModel.C_progress.C_totalBytesWritten;
    C_DLModel.C_progress.C_remainingTime = ceilf(C_remainingContentLength / C_DLModel.C_progress.C_speed);
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        [self B_DLModel:C_DLModel updateProgress:C_DLModel.C_progress];
    });
}

/**
 * 请求完毕（成功|失败）
 */
- (void)URLSession:(NSURLSession *)C_session task:(NSURLSessionTask *)C_task didCompleteWithError:(NSError *)C_error
{
    A_TYDLModel *C_DLModel = [self B_DLingModelForURLString:C_task.taskDescription];
    
    if (!C_DLModel) {
        return;
    }
    
    // 关闭流
    [C_DLModel.C_stream close];
    C_DLModel.C_stream = nil;
    C_DLModel.C_task = nil;
    
    [self B_removeDLingModelForURLString:C_DLModel.C_DLURL];

    if (C_DLModel.C_manualCancle) {
        // 暂停下载
        dispatch_async(dispatch_get_main_queue(), ^(){
            C_DLModel.C_manualCancle = NO;
            C_DLModel.C_state = C_TYDLStateSuspended;
            [self B_DLModel:C_DLModel didChangeState:C_TYDLStateSuspended filePath:nil error:nil];
            [self B_willResumeNextWithDowloadModel:C_DLModel];
        });
    }else if (C_error){
        // 下载失败
        dispatch_async(dispatch_get_main_queue(), ^(){
            C_DLModel.C_state = C_TYDLStateFailed;
            [self B_DLModel:C_DLModel didChangeState:C_TYDLStateFailed filePath:nil error:C_error];
            [self B_willResumeNextWithDowloadModel:C_DLModel];
        });
    }else if ([self B_isDLCompletedWithDLModel:C_DLModel]) {
        // 下载完成
        dispatch_async(dispatch_get_main_queue(), ^(){
            C_DLModel.C_state = C_TYDLStateCompleted;
            [self B_DLModel:C_DLModel didChangeState:C_TYDLStateCompleted filePath:C_DLModel.C_filePath error:nil];
            [self B_willResumeNextWithDowloadModel:C_DLModel];
        });
    }else {
        // 下载完成
         dispatch_async(dispatch_get_main_queue(), ^(){
             C_DLModel.C_state = C_TYDLStateCompleted;
             [self B_DLModel:C_DLModel didChangeState:C_TYDLStateCompleted filePath:C_DLModel.C_filePath error:nil];
             [self B_willResumeNextWithDowloadModel:C_DLModel];
         });
    }
}

@end
