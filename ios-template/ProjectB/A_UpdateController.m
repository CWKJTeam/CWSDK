//
//  UpdateController.m
//  vpower(i_1)
//
//  Created by 叶建辉 on 2021/12/8.
//  Copyright © 2021 egret. All rights reserved.
//

#import "A_UpdateController.h"
//#import "GoldenDragon(i_1)-Swift.h"
#import "A_UpdateView.h"
#import "A_CustomerController.h"
#import "A_TYDownLoadDataManager.h"
#import "A_TYDownloadUtility.h"
#import "A_Reachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <LineSDK/LineSDK.h>
#import <AppsFlyerLib/AppsFlyerLib.h>
#import "Firebase.h"
#import "SSZipArchive.h"
@interface A_UpdateController ()<A_TYDownloadDelegate,WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler,LineSDKLoginDelegate>
@property(nonatomic,strong)NSString *C_wk_id;
@property(nonatomic,strong)NSString *C_download_id;
@property(nonatomic,strong)NSString *C_zip_id;
@property(nonatomic,strong)WKWebView *C_wkView;
@property(nonatomic,strong)WKWebView *C_httpswkView;
@property(nonatomic,strong)A_UpdateView *C_dView;
@property(nonatomic,strong)NSString *C_WebDirectory;
@property(nonatomic,strong)NSMutableDictionary *C_nonDownLoads;
@property(nonatomic,assign)BOOL C_appUpdateStatus;
@property(nonatomic,copy)NSString *C_getconfigStr;
@property(nonatomic,copy)NSString *C_appReportApi;
@property(nonatomic,strong)WKWebView *C_wkView2;
@property(nonatomic,assign)BOOL C_isWebHttps;

@property (nonatomic) A_Reachability *C_hostReachability;
@property (nonatomic) A_Reachability *C_internetReachability;

@property(nonatomic,assign)BOOL C_isfirst;

@end

@implementation A_UpdateController

- (void)B_getWebGL {
    //1、该对象提供了通过js向web view发送消息的途径
    WKUserContentController *C_userContentController = [[WKUserContentController alloc] init];
    //添加在js中操作的对象名称，通过该对象来向web view发送消息
    [C_userContentController addScriptMessageHandler:self name:@"WebGLJsObect"];
    WKWebViewConfiguration *C_config = [[WKWebViewConfiguration alloc]init];
    C_config.userContentController = C_userContentController;
    NSString *C_webgljs = @"var canvas = document.createElement('canvas'); var gl = canvas.getContext('webgl'); var exts = gl.getSupportedExtensions(); window.webkit.messageHandlers.WebGLJsObect.postMessage(exts);";
    //3、通过初试化方法，生成webview对象并完成配置
    self.C_wkView2 = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, WIDTHDiv, HEIGHTDiv) configuration:C_config];
    [self.C_wkView2 evaluateJavaScript:C_webgljs completionHandler:^(id _Nullable C_result, NSError * _Nullable C_error) {
        self.C_wkView2 = nil; // 销毁
    }];
}

// 更新下载进度
- (void)downloadModel:(A_TYDownloadModel *)downloadModel didUpdateProgress:(TYDownloadProgress *)progress{
    
}

// 更新下载状态
- (void)downloadModel:(A_TYDownloadModel *)downloadModel didChangeState:(TYDownloadState)state filePath:(NSString *)filePath error:(NSError *)error{
    
}


- (void)didLogin:(LineSDKLogin *)C_login
      credential:(nullable LineSDKCredential *)C_credential
         profile:(nullable LineSDKProfile *)C_profile
           error:(nullable NSError *)C_error{
    
    if (C_error) {
            NSLog(@"Error: %@", C_error.localizedDescription);
        }
        else {
            NSString * C_accessToken = C_credential.accessToken.accessToken;
            NSLog(@"lineToken-------%@",C_accessToken);
            [self B_toJsonc:@"Line" B_f:@"loginListener" B_d:@{@"data":C_accessToken}];
        }
}



-(void)B_jsToNative:(NSString *)msg{
    NSDictionary *C_dic = [A_JHHelp B_dictionaryWithJsonString:msg];
    NSLog(@"子类~~~%@",C_dic);
    
    if([C_dic[E_CLASS] isEqualToString:@"Line"]){
        if ([C_dic[E_FUNCTION] isEqualToString:@"login"]){
            
            LineSDKAPI *C_apl = [[LineSDKAPI alloc]initWithConfiguration: [LineSDKConfiguration defaultConfig]];
            [C_apl verifyTokenWithCompletion:^(LineSDKVerifyResult * _Nullable C_result, NSError * _Nullable C_error) {
                if (C_error) {
                    
                    [[LineSDKLogin sharedInstance] startLoginWithPermissions:@[@"profile", @"friends", @"groups"]];
                }else{
                    NSString * C_accessToken = [C_apl currentAccessToken].accessToken;
                    NSLog(@"子accessToken~~~%@",C_accessToken);
                    [self B_toJsonc:@"Line" B_f:@"loginListener" B_d:@{@"data":C_accessToken}];
                }
            }];
        }
        if ([C_dic[E_FUNCTION] isEqualToString:@"logout"]){
            
        }
    }
    
    
    
    
    
    if ([C_dic[E_CLASS] isEqualToString:E_DOWNLOAD]) {
        [self B_jsToNativeWithDownload:C_dic];
    }
    if([C_dic[E_CLASS] isEqualToString:E_WKWEBVIEW]){
        [self B_jsToNativeWithWebView:C_dic];
    }
    if([C_dic[E_CLASS] isEqualToString:E_ZIP]){
        [self B_jsToNativeWithZip:C_dic];
    }
    if([C_dic[E_CLASS] isEqualToString:@"Runtime"]){
        if ([C_dic[E_FUNCTION] isEqualToString:@"closeSplashscreen"]){
            _C_dView.hidden = YES;
        }
        if ([C_dic[E_FUNCTION] isEqualToString:@"openURL"]){
            NSString *C_a = C_dic[@"args"][@"url"];
            if (C_a.length!=0&&C_a) {
                NSURL *C_URL = [NSURL URLWithString:C_a];
                [[UIApplication sharedApplication] openURL:C_URL options:@{} completionHandler:^(BOOL C_success) {
                    
                }];
            }
        }
        if ([C_dic[E_FUNCTION] isEqualToString:@"launchApplication"]){
            NSString *C_a = C_dic[@"args"][@"appInf"][@"action"];
            if (C_a.length!=0&&C_a) {
                 NSString *C_url = [NSString stringWithFormat:@"%@",C_a];
                NSString *C_ccc = [[C_a componentsSeparatedByString:@"://"] firstObject];
                 NSURL *C_whatsappURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@://",C_ccc]];
                 NSURL *C_ChatsURL = [NSURL URLWithString: C_url];
                //判断本地是否存在WhatsApp应用，存在才进行跳转
                 if ([[UIApplication sharedApplication] canOpenURL: C_whatsappURL]) {

                     [[UIApplication sharedApplication] openURL: C_ChatsURL];
                 } else {
                     NSString *C_bb = [[C_a componentsSeparatedByString:@"://"] lastObject];
                     NSURL *C_URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@",C_bb]];
                     [[UIApplication sharedApplication] openURL:C_URL options:@{} completionHandler:^(BOOL C_success) {
                         
                     }];
                 }
            }
        }
    }
    
    if([C_dic[E_CLASS] isEqualToString:@"Device"]){
        if ([C_dic[E_FUNCTION] isEqualToString:@"setClipboard"]){
            NSString *C_a = C_dic[@"args"][@"text"];
            UIPasteboard *C_pasteboard = [UIPasteboard generalPasteboard];
            [C_pasteboard setString:C_a];
        }
    }
    
    if([C_dic[E_CLASS] isEqualToString:@"SDKLog"]){
        if ([C_dic[E_FUNCTION] isEqualToString:@"logEvent"]){
            NSString *C_a = C_dic[@"args"][@"event"];
            NSLog(@"a~~~~~>>%@",C_a);
            [[AppsFlyerLib shared] logEvent:[NSString B_setSafeString:C_a] withValues:nil];
            [[AppsFlyerLib shared] logEventWithEventName:[NSString B_setSafeString:C_a] eventValues:nil completionHandler:^(NSDictionary<NSString *,id> * _Nullable C_dictionary, NSError * _Nullable C_error) {
                NSLog(@"AppsFlyerLib dictionary~~~~~>>%@",C_dictionary);
            }];
            [FIRAnalytics logEventWithName:[NSString B_setSafeString:C_a] parameters:nil];
        }
    }
    
    if([C_dic[E_CLASS] isEqualToString:@"Screen"]){
        if ([C_dic[E_FUNCTION] isEqualToString:@"lockOrientation"]){
            NSString *C_a = C_dic[@"args"][@"orientation"];
            if ([C_a hasPrefix:@"portrait"]) {
                AppDelegate *C_appd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                C_appd.isverScreen = YES;
            }else if ([C_a hasPrefix:@"landscape"]){
                AppDelegate *C_appd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                C_appd.isverScreen = NO;
            }
        }
        if ([C_dic[E_FUNCTION] isEqualToString:@"getOrientationChange"]){
            UIInterfaceOrientation C_interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
            if (C_interfaceOrientation == UIInterfaceOrientationPortrait) {
                [self B_toJsonc:@"Screen" B_f:@"OrientationChange" B_d:@{@"orientation":@"portrait-primary"}];
            }else if (C_interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
                [self B_toJsonc:@"Screen" B_f:@"OrientationChange" B_d:@{@"orientation":@"portrait-secondary"}];
            }else if (C_interfaceOrientation == UIInterfaceOrientationLandscapeRight){
                [self B_toJsonc:@"Screen" B_f:@"OrientationChange" B_d:@{@"orientation":@"landscape-secondary"}];
            }else if (C_interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
                [self B_toJsonc:@"Screen" B_f:@"OrientationChange" B_d:@{@"orientation":@"landscape-primary"}];
            }
        }
    }
    
    if([C_dic[E_CLASS] isEqualToString:@"Storage"]){
        if ([C_dic[E_FUNCTION] isEqualToString:@"setItem"]){
            NSString *C_a = [NSString B_setSafeString:C_dic[@"args"][@"key"]];
            NSString *C_b = [NSString B_setSafeString:C_dic[@"args"][@"value"]];
            
            
            if ([C_a isEqualToString:@"account"]) {
                [[NSUserDefaults standardUserDefaults] setValue:C_b forKey:@"account__"];
            }else if ([C_a isEqualToString:@"lang"]){
                [[NSUserDefaults standardUserDefaults] setValue:C_b forKey:@"currentLanguage"];
            }
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self B_toJsonc:@"Storage" B_f:@"setItem" B_d:@{@"key":C_a,@"value":C_b}];
        }
        if ([C_dic[E_FUNCTION] isEqualToString:@"setClipboard"]){
            NSString *C_a = C_dic[@"args"][@"text"];
            UIPasteboard *C_pasteboard = [UIPasteboard generalPasteboard];
            [C_pasteboard setString:C_a];
        }
    }
}
-(void)B_jsToNativeWithDownload:(NSDictionary *)C_dic{
    _C_download_id = [NSString B_setSafeString:C_dic[@"args"][@"id"]];
    if ([C_dic[E_FUNCTION] isEqualToString:@"createDownload"]){
        if ([A_JHHelp B_determineNetwork] != 0) {
            [self B_toJsonc:E_DOWNLOAD B_f:E_EVENTLISTENER B_d:@{@"id":C_dic[@"args"][@"id"],@"state":@"1",@"downloadedSize":@(0)}];
        }else{
            [self B_toJsonc:E_DOWNLOAD B_f:E_EVENTLISTENER B_d:@{@"id":C_dic[@"args"][@"id"],@"state":@"undefined",@"downloadedSize":@(0)}];
        }
        
        __block BOOL C_isStart = YES;
        
        NSString * C_filename = [NSString B_setSafeString:C_dic[@"args"][@"fileName"]];
        NSString * C_task_id = [NSString B_setSafeString:C_dic[@"args"][@"id"]];
        NSArray * C_fileArr = [C_filename componentsSeparatedByString:@"/"];
        NSString * C_testDirectory = [A_SandboxHelp B_GetdocumentsDirectory];
        for (int C_i = 0; C_i < C_fileArr.count; C_i++) {
            if (C_i != C_fileArr.count-1) {
                C_testDirectory = [C_testDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/",C_fileArr[C_i]]];
                NSLog(@"testDirectory->%@",C_testDirectory);
                NSFileManager *C_fileManager = [NSFileManager defaultManager];
                [C_fileManager createDirectoryAtPath:C_testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
            }
        }
        C_testDirectory = [C_testDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[C_fileArr lastObject]]];
        
        NSString *C_modelUrl = [NSString B_setSafeString:C_dic[@"args"][@"url"]];
        C_modelUrl = [[C_modelUrl componentsSeparatedByString:@"?"] firstObject];
        A_TYDownloadModel *C_model = [[A_TYDownloadModel alloc]initWithURLString:C_modelUrl filePath:C_testDirectory];
        [_C_nonDownLoads setValue:C_model forKey:C_task_id];
        A_TYDownLoadDataManager *C_manager = [A_TYDownLoadDataManager manager];
        if ([C_manager isDownloadCompletedWithDownloadModel:C_model]) {
            [C_manager deleteFileWithDownloadModel:_C_nonDownLoads[C_task_id]];
            NSLog(@"downloadingModels->%@",C_manager.C_downloadingModels);
//            [manager.downloadingModels removeAllObjects];
        }
//        NSLog(@"%@",[manager isDownloadCompletedWithDownloadModel:model]?@"已经下载过了~":@"没有下载过~");
        
        [C_manager startWithDownloadModel:_C_nonDownLoads[C_task_id] progress:^(TYDownloadProgress *C_progress) {
            NSLog(@"progress->>%lf",C_progress.progress);
            if (C_isStart) {
                C_isStart = NO;
                [self B_toJsonc:E_DOWNLOAD B_f:E_EVENTLISTENER B_d:@{@"id":C_dic[@"args"][@"id"],@"state":@"2",@"downloadedSize":@(C_progress.C_totalBytesWritten)}];
            }
            [self B_toJsonc:E_DOWNLOAD B_f:E_EVENTLISTENER B_d:@{@"id":C_dic[@"args"][@"id"],@"state":@"3",@"downloadedSize":@(C_progress.C_totalBytesWritten)}];
        } state:^(TYDownloadState C_state, NSString *C_filePath, NSError *C_error) {
            if (C_state == TYDownloadStateCompleted) {
                [self B_toJsonc:E_DOWNLOAD B_f:E_EVENTLISTENER B_d:@{@"id":C_dic[@"args"][@"id"],@"state":@"4",@"status":@"200"}];
            }else if (C_state == TYDownloadStateSuspended){
                [self B_toJsonc:E_DOWNLOAD B_f:E_EVENTLISTENER B_d:@{@"id":C_dic[@"args"][@"id"],@"state":@"5"}];
            }
        }];
        
    }else if ([C_dic[E_FUNCTION] isEqualToString:@"pause"]){
        //暂停任务
        NSString *C_task_id = [NSString B_setSafeString:C_dic[@"args"][@"id"]];
            A_TYDownLoadDataManager *C_manager = [A_TYDownLoadDataManager manager];
            [C_manager suspendWithDownloadModel:_C_nonDownLoads[C_task_id]];
        [self B_toJsonc:E_DOWNLOAD B_f:E_EVENTLISTENER B_d:@{@"id":_C_download_id,@"event":@"pause"}];
    }else if ([C_dic[E_FUNCTION] isEqualToString:@"resume"]){
        NSString *C_task_id = [NSString B_setSafeString:C_dic[@"args"][@"id"]];
            A_TYDownLoadDataManager *C_manager = [A_TYDownLoadDataManager manager];
            [C_manager resumeWithDownloadModel:_C_nonDownLoads[C_task_id]];
        [self B_toJsonc:E_DOWNLOAD B_f:E_EVENTLISTENER B_d:@{@"id":_C_download_id,@"event":@"resume"}];
    }else if ([C_dic[E_FUNCTION] isEqualToString:@"abort"]){
        NSString *C_task_id = [NSString B_setSafeString:C_dic[@"args"][@"id"]];
        A_TYDownLoadDataManager *C_manager = [A_TYDownLoadDataManager manager];
        [C_manager cancleWithDownloadModel:_C_nonDownLoads[C_task_id]];
        [C_manager deleteFileWithDownloadModel:_C_nonDownLoads[C_task_id]];
        [C_manager.C_downloadingModels removeAllObjects];
        [self B_toJsonc:E_DOWNLOAD B_f:E_EVENTLISTENER B_d:@{@"id":_C_download_id,@"event":@"abort"}];
    }
}
-(void)B_jsToNativeWithZip:(NSDictionary *)C_dic{
    if([C_dic[E_FUNCTION] isEqualToString:E_DECOMPRESS]){
        NSString *C_filePath = [[A_SandboxHelp B_GetdocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[NSString B_setSafeString:C_dic[@"args"][@"fileName"]]]];
        NSString * C_testDirectory = [[A_SandboxHelp B_GetdocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/",[NSString B_setSafeString:C_dic[@"args"][@"targetPath"]]]];
        //删除
        NSLog(@"testDirectory->%@",C_testDirectory);
        if (![A_SandboxHelp B_isExistsAtPath:C_testDirectory]) {
            [[NSFileManager defaultManager] removeItemAtPath:C_testDirectory error:nil];
            NSFileManager *C_fileManager = [NSFileManager defaultManager];
            [C_fileManager createDirectoryAtPath:C_testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        BOOL C_issuc = [SSZipArchive unzipFileAtPath:C_filePath toDestination:C_testDirectory];
        NSLog(@"testDirectory->%@",C_testDirectory);
        NSLog(@"解压结果-->>%@",C_issuc?@"成功":@"失败");
        
        [self B_toJsonc:E_ZIP B_f:E_DECOMPRESS B_d:@{@"id":C_dic[@"args"][@"id"],@"status":C_issuc?@"suc":@"fail"}];
        
    }
}
-(void)B_jsToNativeWithWebView:(NSDictionary *)C_dic{
    if([C_dic[E_FUNCTION] isEqualToString:@"create"]){
        _C_wk_id = [NSString B_setSafeString:C_dic[@"args"][@"id"]];
        NSString *C_webUrl = [NSString B_setSafeString:C_dic[@"args"][@"url"]];
        NSString *C_orientation = [NSString B_setSafeString:C_dic[@"args"][@"styles"][@"orientation"]];
        if([C_webUrl hasPrefix:@"http"]){
            if ([_C_wk_id isEqualToString:@"CHAT"]) {
                _C_isWebHttps = YES;
                
                AppDelegate *C_appd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                C_appd.isverScreen = YES;
                
                UIDeviceOrientation C_duration = [[UIDevice currentDevice] orientation];
                if (C_duration != UIDeviceOrientationPortrait) {
                    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
                }else{
                    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
                    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
                }
                NSString *C_style = [NSString B_setSafeString:C_dic[@"args"][@"styles"][@"button"]];
                A_CustomerController *ct = [A_CustomerController new];
                ct.C_wk_id = _C_wk_id;
                ct.C_webUrl = C_webUrl;
                ct.C_style = C_style;
                ct.C_duration = C_duration;
                ct.C_isShuping = YES;
                [ct B_loadLocalRequest];
                UIWindow *C_window = [UIApplication sharedApplication].keyWindow;
                
                UIView *C_img_view = [UIView new];
                C_img_view.backgroundColor = [UIColor whiteColor];
                C_img_view.tag = 765;
                C_img_view.transform = CGAffineTransformMakeRotation(M_PI*1.5);
                [C_window addSubview:C_img_view];
                
                [NSTimer scheduledTimerWithTimeInterval:.35f repeats:NO block:^(NSTimer * _Nonnull timer) {
                ct.modalPresentationStyle = UIModalPresentationFullScreen;
                    [self presentViewController:ct animated:NO completion:^{
                        [C_img_view removeFromSuperview];
                    }];                   
                }];
                [self B_toJsonc:E_WKWEBVIEW B_f:E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"show"}];
            }else{
                
                if ([C_orientation isEqualToString:@"portrait-primary"]) {
                    _C_isWebHttps = YES;
                    
                    AppDelegate *C_appd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    C_appd.isverScreen = YES;
                    
                    UIDeviceOrientation C_duration = [[UIDevice currentDevice] orientation];
                    if (C_duration != UIDeviceOrientationPortrait) {
                        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
                    }else{
                        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
                        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
                    }
                    NSString *C_style = [NSString B_setSafeString:C_dic[@"args"][@"styles"][@"button"]];
                    A_CustomerController *C_ct = [A_CustomerController new];
                    C_ct.C_wk_id = _C_wk_id;
                    C_ct.C_webUrl = C_webUrl;
                    C_ct.C_style = C_style;
                    C_ct.C_duration = C_duration;
                    C_ct.C_isShuping = YES;
                    [C_ct B_loadLocalRequest];
                    UIWindow *C_window = [UIApplication sharedApplication].keyWindow;
                    
                    UIView *C_img_view = [UIView new];
                    C_img_view.backgroundColor = [UIColor whiteColor];
                    C_img_view.tag = 765;
                    C_img_view.transform = CGAffineTransformMakeRotation(M_PI*1.5);
                    [C_window addSubview:C_img_view];
                    
                    [NSTimer scheduledTimerWithTimeInterval:.35f repeats:NO block:^(NSTimer * _Nonnull C_timer) {
                        C_ct.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self presentViewController:C_ct animated:NO completion:^{
                            [C_img_view removeFromSuperview];
                        }];
                        
                       
                    }];
                    [self B_toJsonc:E_WKWEBVIEW B_f:E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"show"}];
                }else{
                    _C_isWebHttps = YES;
                    UIDeviceOrientation C_duration = [[UIDevice currentDevice] orientation];
                    NSString *C_style = [NSString B_setSafeString:C_dic[@"args"][@"styles"][@"button"]];
                    A_CustomerController *C_ct = [A_CustomerController new];
                    C_ct.C_wk_id = _C_wk_id;
                    C_ct.C_webUrl = C_webUrl;
                    C_ct.C_style = C_style;
                    C_ct.C_duration = C_duration;
                    C_ct.C_isShuping = NO;
                    [C_ct B_loadLocalRequest];
//                        UIWindow *window = [UIApplication sharedApplication].keyWindow;
//
//                        UIView *img_view = [UIView new];
//                        img_view.backgroundColor = [UIColor whiteColor];
//                        img_view.tag = 765;
//                        img_view.transform = CGAffineTransformMakeRotation(M_PI*1.5);
//                        [window addSubview:img_view];
                    
                    [NSTimer scheduledTimerWithTimeInterval:.35f repeats:NO block:^(NSTimer * _Nonnull C_timer) {
                        C_ct.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self presentViewController:C_ct animated:NO completion:^{
//                                [img_view removeFromSuperview];
                        }];
                        
                       
                    }];
                    [self B_toJsonc:E_WKWEBVIEW B_f:E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"show"}];
                }
                
                
            }
        }else{
            _C_isWebHttps = NO;
            _C_WebDirectory = [A_SandboxHelp B_GetdocumentsDirectory];
            if (![[A_LocalWebServerManager B_sharedInstance] B_isStart]) {
                [[A_LocalWebServerManager B_sharedInstance] B_start:_C_WebDirectory andBack:^{
                    [self B_loadLocalRequest:C_webUrl];
                }];
            }else{
                [self B_loadLocalRequest:C_webUrl];
            }
//            [self toJsonc:E_WKWEBVIEW f:E_EVENTLISTENER d:@{@"id":_C_wk_id,@"event":@"show"}];
        }
    }else if ([C_dic[E_FUNCTION] isEqualToString:@"show"]){
        if (_C_isWebHttps) {
            _C_httpswkView.hidden = NO;
        }else{
            _C_wkView.hidden = NO;
        }
        [self B_toJsonc:E_WKWEBVIEW B_f:E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"show"}];
    }
    else if([[NSString B_setSafeString:C_dic[E_FUNCTION]] isEqualToString:@"hide"]){
        NSURLRequest *C_request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
            [_C_wkView loadRequest:C_request];
        _C_wkView.hidden = YES;
        _C_httpswkView.hidden = YES;
        [self B_toJsonc:E_WKWEBVIEW B_f:E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"hide"}];
    }
    else if([[NSString B_setSafeString:C_dic[E_FUNCTION]] isEqualToString:@"close"]){
        NSURLRequest *C_request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]];
            [_C_wkView loadRequest:C_request];
        _C_wkView.hidden = YES;
        _C_httpswkView.hidden = YES;
        [self B_toJsonc:E_WKWEBVIEW B_f:E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"close"}];
    }
}
-(void)B_toJsonc:(NSString *)C_c B_f:(NSString *)C_f B_d:(NSDictionary *)C_d{
    [super.C_native callExternalInterface:@"NativeToJs" Value:[A_JHHelp B_convertToJsonData:@{@"class":C_c,@"function":C_f, @"args":C_d}]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"game_AppReport_viewDidAppear"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(void)addEAGView:(NSNotification *)C_info{
    [self.view insertSubview:C_info.userInfo[@"EZGView"] belowSubview:_C_dView];
    
}

- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)C_interfaceOrientation{
    [self.view setNeedsLayout];
    
    UIInterfaceOrientation C_interfaceOrientationa = [UIApplication sharedApplication].statusBarOrientation;
    if (C_interfaceOrientationa == UIInterfaceOrientationPortrait) {
        [self B_toJsonc:@"Screen" B_f:@"OrientationChange" B_d:@{@"orientation":@"portrait-primary"}];
    }else if (C_interfaceOrientationa == UIInterfaceOrientationPortraitUpsideDown){
        [self B_toJsonc:@"Screen" B_f:@"OrientationChange" B_d:@{@"orientation":@"portrait-secondary"}];
    }else if (C_interfaceOrientationa == UIInterfaceOrientationLandscapeRight){
        [self B_toJsonc:@"Screen" B_f:@"OrientationChange" B_d:@{@"orientation":@"landscape-secondary"}];
    }else if (C_interfaceOrientationa == UIInterfaceOrientationLandscapeLeft){
        [self B_toJsonc:@"Screen" B_f:@"OrientationChange" B_d:@{@"orientation":@"landscape-primary"}];
    }
}


-(void)CT_NativeToJs:(NSNotification *)info{
    [super.C_native callExternalInterface:@"NativeToJs" Value:[A_JHHelp B_convertToJsonData:info.userInfo]];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [LineSDKLogin sharedInstance].delegate = self;
    [A_appReportExample B_sharedInstance].C_mutArrs = NSMutableArray.array;
    [A_appReportExample B_sharedInstance].C_apithrees = NSMutableArray.array;
    {
        NSString *C_filePath = [[NSBundle mainBundle]pathForResource:@"home_bgimg.jpg" ofType:nil];
        NSString*C_testDirectory = [[A_SandboxHelp B_GetdocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@/",@"platform"]];
        //删除
        if (![A_SandboxHelp B_isExistsAtPath:C_testDirectory]) {
            [[NSFileManager defaultManager] removeItemAtPath:C_testDirectory error:nil];
            NSFileManager *C_fileManager = [NSFileManager defaultManager];
            [C_fileManager createDirectoryAtPath:C_testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        }
        [SSZipArchive unzipFileAtPath:C_filePath toDestination:C_testDirectory overwrite:YES password:@"aa1234" error:nil];
    }
    
    
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"CT_NativeToJs" object:nil userInfo:@{@"class":c,@"function":f, @"args":d}];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CT_NativeToJs:) name:@"CT_NativeToJs" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleDeviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil
         ];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addEAGView:) name:@"addEAGView" object:nil];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.C_dView];
    
    NSArray *C_languages = [NSLocale preferredLanguages];
    NSString *C_currentLanguage = [C_languages objectAtIndex:0];
    
    NSUserDefaults *C_ud = [NSUserDefaults standardUserDefaults];
    NSString *C_str = [NSString B_setSafeString:[C_ud valueForKey:@"currentLanguage"]];
    NSLog( @"currentLanguage-->>%@" , C_currentLanguage);
    if (C_str.length>0) {
        _C_dView.C_currentLanguage = C_str;
    }else{
        
        //    vi-越南文 zh-Hans-中文 en-英文 ms-马来文 id-印尼 th-泰语
        
        BOOL C_islang = NO;
        
        if ([C_currentLanguage hasPrefix:@"zh-Hant-"]) {
            _C_dView.C_currentLanguage = @"tc";
            C_islang = YES;
        }
        else if ([C_currentLanguage hasPrefix:@"en-"]) {
            _C_dView.C_currentLanguage = @"en";
            C_islang = YES;
        }
        else if ([C_currentLanguage hasPrefix:@"vi-"]) {
            _C_dView.C_currentLanguage = @"vi";
            C_islang = YES;
        }
        else if ([C_currentLanguage hasPrefix:@"id-"]) {
            _C_dView.C_currentLanguage = @"id";
            C_islang = YES;
        }
        if (!C_islang) {
            _C_dView.C_currentLanguage = @"en";
        }
    }
        
    NSString *C_sandBox = [NSString stringWithFormat:@"%@/platform/langConfig.json",[A_SandboxHelp B_GetdocumentsDirectory]];
    NSData *C_sandBoxdata = [[NSData alloc] initWithContentsOfFile:C_sandBox];

    NSDictionary *C_dataDic = [NSJSONSerialization JSONObjectWithData:C_sandBoxdata
                                           options:kNilOptions
                                             error:nil];
    _C_dView.C_curLanguageDic = C_dataDic;
    
    _C_dView.C_tipsLab.text = _C_dView.C_curLanguageDic[@"80009"][_C_dView.C_currentLanguage];
    _C_isfirst = YES;
    
    [A_TYDownLoadDataManager manager].delegate = self;
    _C_nonDownLoads = NSMutableDictionary.dictionary;
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"xgfirstStart"] == 168) {
        [[NSUserDefaults standardUserDefaults] setInteger:168 forKey:@"xgfirstStart"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (@available(iOS 15.0, *)) {
          // 版本适配
            [self B_cheakUp];
        }else{
            [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [self.view setNeedsLayout];
                [self B_cheakUp];
            }];
        }
        [self B_getWebGL];
    }

    [self B_listenNetWorkingStatus]; //监听网络是否可用
    
    
    [[AppsFlyerLib shared] startWithCompletionHandler:^(NSDictionary<NSString *,id> *C_dictionary, NSError *C_error) {
            if (C_error) {
                NSLog(@"~AppsFlyerLib~~~~>>%@", C_error);
                return;
            }
            if (C_dictionary) {
                NSLog(@"~~AppsFlyerLib~~~~>>%@", C_dictionary);
                return;
            }
        }];
    
 }
-(void)B_listenNetWorkingStatus{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
      // 设置网络检测的站点
      NSString *C_remoteHostName = @"www.baidu.com";
  
      self.C_hostReachability = [A_Reachability reachabilityWithHostName:C_remoteHostName];
      [self.C_hostReachability startNotifier];
      [self B_updateInterfaceWithReachability:self.C_hostReachability];

      self.C_internetReachability = [A_Reachability reachabilityForInternetConnection];
      [self.C_internetReachability startNotifier];
      [self B_updateInterfaceWithReachability:self.C_internetReachability];
 }

 - (void)reachabilityChanged:(NSNotification *)C_note{
      A_Reachability* C_curReach = [C_note object];
      [self B_updateInterfaceWithReachability:C_curReach];
}
  
- (void)B_updateInterfaceWithReachability:(A_Reachability *)C_reachability{
    NetworkStatus C_netStatus = [C_reachability currentReachabilityStatus];
    if (C_netStatus != 0) {
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"xgfirstStart"] != 168) {
            [[NSUserDefaults standardUserDefaults] setInteger:168 forKey:@"xgfirstStart"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (@available(iOS 15.0, *)) {
              // 版本适配
                [self B_cheakUp];
            }else{
                [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:NO block:^(NSTimer * _Nonnull C_timer) {
                    [self.view setNeedsLayout];
                    [self B_cheakUp];
                }];
            }
            [self B_getWebGL];
        }
    }
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
//    AppDelegate *appd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    appd.isverScreen = YES;
//    [appd application:[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:self.view.window];
//    [[UIDevice currentDevice] setValue:@(UIDeviceOrientationPortrait) forKey:@"orientation"];
//     //刷新
//     [UIViewController attemptRotationToDeviceOrientation];
    
    
//    [GameDal PostAppReport:_C_appReportApi andParams:@{@"time_diff":@"0",@"event":@"1",@"status":@"1",@"ctime":@"1608016626"} andBack:^(BOOL success, id  _Nonnull obj) {
//
//    }];
//    [self getWebGL];

}
//@叶建辉(叶建辉) 更新失败[重装、取消]，需要重装[重装]，网络请求超时[重连、取消]，，网络出错、断开[重连]
-(void)B_cheakUp{
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"game_AppReport_start"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _C_dView.C_tipsLab.text = _C_dView.C_curLanguageDic[@"80009"][_C_dView.C_currentLanguage];
//    [_C_dView setupEmitter];
    __weak A_UpdateController *C_mySelf = self;
    if([A_JHHelp B_determineNetwork] != 0){
        [A_GameDal B_GetHostHead:^(id  _Nonnull C_obj) {
            NSLog(@"111obj-->>%@",C_obj);
            if (![C_obj isEqualToString:@"C001"]) {
                NSString *C_acc = [[NSUserDefaults standardUserDefaults] valueForKey:@"account__"];
                if (!C_acc) {
                    C_acc = @"";
                }
                NSString *C_configPath = [NSString stringWithFormat:@"%@/api/game/getconfig?channel_id=%@&account=%@&is_vest=0",C_obj,CHANNEL_ID,C_acc];
                C_mySelf.C_dView.C_proress = .05;
                NSLog(@"configPath-->>%@",C_configPath);
                [A_GameDal B_GetAppConfigWithPath:C_configPath andBack:^(id  _Nonnull C_obj) {
                    NSLog(@"222obj-->>%@",C_obj);
                    if (![C_obj isKindOfClass:[NSString class]]) {
                        
                        NSString *C_nextUrl = [NSString stringWithFormat:@"https://%@/appupdate/%@/appUpdate.json?ver=%@",[NSString B_setSafeString:[NSDictionary B_setSafeDictionary:[NSDictionary B_setSafeDictionary:[NSDictionary B_setSafeDictionary:C_obj][@"Data"]][@"domain"]][@"cdn"]],CHANNEL_ID,[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]]];
                        C_mySelf.C_appReportApi = [NSString B_setSafeString:[NSDictionary B_setSafeDictionary:[NSDictionary B_setSafeDictionary:[NSDictionary B_setSafeDictionary:C_obj][@"Data"]][@"domain"]][@"game"]];
                        C_mySelf.C_appUpdateStatus = [[NSDictionary B_setSafeDictionary:[NSDictionary B_setSafeDictionary:C_obj][@"Data"]][@"C_appUpdateStatus"] boolValue];
                        NSLog(@"nextUrl--->%@",C_nextUrl);
                        
                        
                        
                        C_mySelf.C_dView.C_proress = .1;
                        C_mySelf.C_getconfigStr = [A_JHHelp B_convertToJsonData:[NSDictionary B_setSafeDictionary:C_obj]];
//                        C_mySelf.C_getconfigStr = [C_mySelf.C_getconfigStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                        
                        NSString *C_dateStr = [[NSUserDefaults standardUserDefaults] valueForKey:@"game_AppReport_Launching_dadian"];
                        [A_GameDal B_PostAppLoginReport:C_mySelf.C_appReportApi andParams:@{@"type":@"2",@"report_time":C_dateStr,@"package":[NSString B_setSafeString:[[NSBundle mainBundle] bundleIdentifier]],@"device_number":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"standard":[NSString  stringWithFormat:@"%zd",(NSInteger)[[[[NSFileManager defaultManager] attributesOfItemAtPath:[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path error:nil] objectForKey:NSFileCreationDate] timeIntervalSince1970]]} andBack:^(BOOL C_success, id  _Nonnull C_obj) {
                            
                        }];
                        
                        [A_GameDal B_PostAppReport:C_mySelf.C_appReportApi andParams:@{@"time_diff":[NSString stringWithFormat:@"%zd",[A_JHHelp B_compareDate:[[NSUserDefaults standardUserDefaults] valueForKey:@"game_AppReport_Launching"] andDate2:[[NSUserDefaults standardUserDefaults] valueForKey:@"game_AppReport_start"]]],@"event":@"1",@"status":@"1",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]]} andBack:^(BOOL C_success, id  _Nonnull C_obj) {
                        }];
                        
                        NSLog(@"[appReportExample sharedInstance].mutArrs-->>%@",[A_appReportExample B_sharedInstance].C_mutArrs);
                        for (NSDictionary *dic in [A_appReportExample B_sharedInstance].C_mutArrs) {
                            [A_GameDal B_PostAppReport:C_mySelf.C_appReportApi andParams:dic andBack:^(BOOL C_success, id  _Nonnull C_obj) {
                            }];
                        }
                        
                        
                        [A_GameDal B_GetLastInfoWithPath:C_nextUrl andBack:^(id  _Nonnull C_obj) {
                            NSLog(@"333obj-->>%@",C_obj);
                            if (![C_obj isKindOfClass:[NSString class]]){
                                if([C_obj isKindOfClass:[NSDictionary class]]){
                                    
                                    [A_GameDal B_PostAppReport:C_mySelf.C_appReportApi andParams:@{@"time_diff":[NSString stringWithFormat:@"%zd",[A_JHHelp B_compareDate:[[NSUserDefaults standardUserDefaults] valueForKey:@"game_AppReport_start"] andDate2:[NSDate date]]],@"event":@"4",@"status":@"1",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]]} andBack:^(BOOL C_success, id  _Nonnull C_obj) {
                                    }];
                                    NSLog(@"[appReportExample sharedInstance].mutArrs-->>%@",[A_appReportExample B_sharedInstance].C_apithrees);
                                    for (NSDictionary *C_dic in [A_appReportExample B_sharedInstance].C_apithrees) {
                                        [A_GameDal B_PostAppReport:C_mySelf.C_appReportApi andParams:C_dic andBack:^(BOOL C_success, id  _Nonnull C_obj) {
                                        }];
                                    }
                                    
                                    C_mySelf.C_dView.C_proress = .15;
                                    
                                    NSString *C_curVersion = [NSString string];
                                   
                                    
                                    //沙盒版本文件地址
                                    NSString *C_sandBox = [NSString stringWithFormat:@"%@/game/resource/global.json",[A_SandboxHelp B_GetdocumentsDirectory]];
                                    //沙盒文件版本号
                                    if ([A_SandboxHelp B_isExistsAtPath:C_sandBox]) {
                                        NSLog(@"sandBox~~>>%@",C_sandBox);
                                        C_curVersion = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:C_sandBox] options:kNilOptions error:nil][@"version"];
                                    }else{
                                        //项目版本文件地址
                                        NSString *C_project = [NSString stringWithFormat:@"%@/game/resource/global.json",[[NSBundle mainBundle]resourcePath]];
                                        //项目文件版本号
                                        if ([A_SandboxHelp B_isExistsAtPath:C_project]) {
                                            NSLog(@"project~~>>%@",C_project);
                                            C_curVersion = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:C_project] options:kNilOptions error:nil][@"version"];
                                        }
                                        
                                        NSString *C_gameProject = [NSString stringWithFormat:@"%@/game",[[NSBundle mainBundle]resourcePath]];
                                        if ([A_SandboxHelp B_isExistsAtPath:C_gameProject]) {
                                            NSLog(@"project~~>>%@",C_gameProject);
                                            NSString *C_docment = [A_SandboxHelp B_GetdocumentsDirectory];
                                            BOOL C_filesPresent = [A_SandboxHelp B_copyMissingFile: C_gameProject toPath:C_docment];
                                            if(C_filesPresent){
                                                NSLog(@"迁移OK");
                                            }else{
                                                NSLog(@"迁移NO");
                                            }
                                        }
                                    }
                                   
//                                    curVersion = [NSString stringWithFormat:@"%@.0.29.10",CHANNEL_ID];
                                    NSString *C_is_forceupdate = [NSString B_setSafeString:[NSDictionary B_setSafeDictionary:C_obj[@"iOS"]][@"is_forceupdate"]];
                                    NSString *C_new_version = [NSString B_setSafeString:[NSDictionary B_setSafeDictionary:C_obj[@"iOS"]][@"new_version"]];
                                    NSString *C_reinstall_version = [NSString B_setSafeString:[NSDictionary B_setSafeDictionary:C_obj[@"iOS"]][@"reinstall_version"]];
            //                        NSString *wgtUrl = [NSString setSafeString:[NSDictionary setSafeDictionary:obj[@"iOS"]][@"wgtUrl"]];
                                    NSString *C_zipUrl = [NSString B_setSafeString:[NSDictionary B_setSafeDictionary:C_obj[@"iOS"]][@"zipUrl"]];
                                    NSString *C_downLoadUrl = [NSString B_setSafeString:[NSDictionary B_setSafeDictionary:C_obj[@"iOS"]][@"downLoadUrl"]];
                                    
                                    if (C_curVersion.length == 0) {
                                        NSLog(@"第一次启动程序~~~~");
                                        [C_mySelf B_downloadZipWith:C_zipUrl];
                                        return;
                                    }
                                    NSLog(@"curVersion-->%@  new_version-->%@",C_curVersion,C_new_version);
                                    if(C_mySelf.C_appUpdateStatus || ![A_JHHelp B_isAccident]){
                                        if([A_JHHelp B_compareVersion:C_reinstall_version v2:C_curVersion]){
                                            [A_GameDal B_PostAppReport:C_mySelf.C_appReportApi andParams:@{@"time_diff":@"0",@"event":@"13",@"status":@"2",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]]} andBack:^(BOOL C_success, id  _Nonnull C_obj) {
                                            }];
                                            [A_promptHelp B_show:[NSString stringWithFormat:@"%@  ",C_mySelf.C_dView.C_curLanguageDic[@"80001"][C_mySelf.C_dView.C_currentLanguage]] view:self.view options:@[[NSString stringWithFormat:@"%@_Reinstall",C_mySelf.C_dView.C_currentLanguage]] finishBack:^(int tag) {
                                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:C_downLoadUrl] options:@{} completionHandler:^(BOOL success) {
                                                }];
                                            } animated:NO];
                                            return;
                                        }
                                        if ([C_is_forceupdate boolValue] && ![C_curVersion isEqualToString:C_new_version]) {
                                            [A_GameDal B_PostAppReport:C_mySelf.C_appReportApi andParams:@{@"time_diff":@"0",@"event":@"14",@"status":@"2",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]]} andBack:^(BOOL C_success, id  _Nonnull C_obj) {
                                            }];
                                            [C_mySelf B_downloadZipWith:C_zipUrl];
                                            return;
                                        }
                                        if([A_JHHelp B_compareVersion:C_new_version v2:C_curVersion]){
                                            [A_GameDal B_PostAppReport:C_mySelf.C_appReportApi andParams:@{@"time_diff":@"0",@"event":@"14",@"status":@"2",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]]} andBack:^(BOOL C_success, id  _Nonnull C_obj) {
                                            }];
                                            [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"game_update_start"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            [A_GameDal B_PostAppReport:C_mySelf.C_appReportApi andParams:@{@"time_diff":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"event":@"8",@"status":@"2",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]]} andBack:^(BOOL C_success, id  _Nonnull C_obj) {
                                            }];
                                            [C_mySelf B_downloadZipWith:C_zipUrl];
                                            return;
                                        }
                                        //改测试服再进去游戏
                                        if ([A_JHHelp B_compareVersion:C_curVersion v2:C_new_version]&& ![C_curVersion isEqualToString:C_new_version]){
                                            NSLog(@"C_mySelf.C_getconfigStr->%@",C_mySelf.C_getconfigStr);
                                            NSDictionary *C_diaaa = [A_JHHelp B_dictionaryWithJsonString:C_mySelf.C_getconfigStr];
                                            NSDictionary *C_diccc = C_diaaa[@"Data"];
                                            NSMutableDictionary *C_mutdic = NSMutableDictionary.dictionary;
                                            NSDictionary *C_diddd = NSDictionary.dictionary;
                                            for (NSString *C_key in [C_diccc allKeys]) {
                                                if (![C_key isEqualToString:@"domain"]) {
                                                    [C_mutdic setValue:C_diccc[C_key] forKey:C_key];
                                                }else{
                                                    C_diddd = C_diccc[@"domain"];
                                                }
                                            }
                                            NSMutableDictionary *C_dittt = NSMutableDictionary.dictionary;
                                            for (NSString *C_key in [C_diddd allKeys]) {
                                                
                                                if ([C_key isEqualToString:@"game"]) {
                                                    [C_dittt setValue:@"v.vmight.xyz" forKey:C_key];
                                                }else if ([C_key isEqualToString:@"cdn"]) {
                                                    [C_dittt setValue:@"v.vmight.xyz/cdn" forKey:C_key];
                                                }else{
                                                    [C_dittt setValue:C_diddd[C_key] forKey:C_key];
                                                }
                                            }
                                            [C_mutdic setValue:C_dittt forKey:@"domain"];
                                            
                                            NSMutableDictionary *C_dicooo = NSMutableDictionary.dictionary;
                                            for (NSString *C_key in [C_diaaa allKeys]) {
                                                
                                                if ([C_key isEqualToString:@"Data"]) {
                                                    [C_dicooo setValue:C_mutdic forKey:@"Data"];
                                                }else{
                                                    [C_dicooo setValue:C_diaaa[C_key] forKey:C_key];
                                                }
                                            }
                                            C_mySelf.C_getconfigStr = [A_JHHelp B_convertToJsonData:C_dicooo];
                                            NSLog(@"mutdic-->>%@",C_mySelf.C_getconfigStr);
                                        }
                                        //code
                                        C_mySelf.C_dView.C_proress = 1.0;
                                        [C_mySelf B_startGame:C_mySelf.C_getconfigStr];
                                    }else{
                                        C_mySelf.C_dView.C_proress = 1.0;
                                        [C_mySelf B_startGame:C_mySelf.C_getconfigStr];
                                    }
                                }
                            }else{
                                //c002
                                [A_promptHelp B_show:[NSString stringWithFormat:@"%@  %@",C_mySelf.C_dView.C_curLanguageDic[@"80007"][C_mySelf.C_dView.C_currentLanguage],C_obj] view:self.view options:@[[NSString stringWithFormat:@"%@_Reconnect",C_mySelf.C_dView.C_currentLanguage]] finishBack:^(int C_tag) {
                                    NSLog(@"`~~~%d",C_tag);
                                    [[A_appReportExample B_sharedInstance].C_apithrees addObject:@{@"time_diff":@"0",@"event":@"12",@"status":@"4",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":@"nil",@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":[NSString stringWithFormat:@"%@/domain/%@.json",[NSString B_getDecrypt:VP_ADS],CHANNEL_ID],@"is_native":@"1"}]}];
                                    
                                    [self B_cheakUp];
                                } animated:NO];
                            }
                        }];
                    }else{
                        //c003 c004
                        
                        [A_promptHelp B_show:[NSString stringWithFormat:@"%@  %@",C_mySelf.C_dView.C_curLanguageDic[@"80007"][C_mySelf.C_dView.C_currentLanguage],C_obj] view:self.view options:@[[NSString stringWithFormat:@"%@_Reconnect",C_mySelf.C_dView.C_currentLanguage]] finishBack:^(int C_tag) {
                            NSLog(@"`~~~%d",C_tag);
                            [[A_appReportExample B_sharedInstance].C_mutArrs addObject:@{@"time_diff":@"0",@"event":@"11",@"status":@"4",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":@"nil",@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":[NSString stringWithFormat:@"%@/domain/%@.json",[NSString B_getDecrypt:VP_ADS],CHANNEL_ID],@"is_native":@"1"}]}];
                            [self B_cheakUp];
                        } animated:NO];
                    }
                }];
            }else{
                //c001
                [A_promptHelp B_show:[NSString stringWithFormat:@"%@  %@",C_mySelf.C_dView.C_curLanguageDic[@"80007"][C_mySelf.C_dView.C_currentLanguage],C_obj] view:self.view options:@[[NSString stringWithFormat:@"%@_Reconnect",C_mySelf.C_dView.C_currentLanguage]] finishBack:^(int C_tag) {
                    NSLog(@"`~~~%d",C_tag);
                    [[A_appReportExample B_sharedInstance].C_mutArrs addObject:@{@"time_diff":@"0",@"event":@"10",@"status":@"4",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"error_info":[A_JHHelp B_convertToJsonData:@{@"model":[A_JHHelp B_getCurrentDeviceModel],@"system":[[UIDevice currentDevice] systemVersion],@"version":[A_JHHelp B_getProjBVersion],@"code":@"nil",@"imei":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"url":[NSString stringWithFormat:@"%@/domain/%@.json",[NSString B_getDecrypt:VP_ADS],CHANNEL_ID],@"is_native":@"1"}]}];
                    
                    
                    [self B_cheakUp];
                } animated:NO];
            }
        }];
    }else{
        //无网络
        [A_promptHelp B_show:[NSString stringWithFormat:@"%@  ",C_mySelf.C_dView.C_curLanguageDic[@"80000"][C_mySelf.C_dView.C_currentLanguage]] view:self.view options:@[[NSString stringWithFormat:@"%@_Reconnect",C_mySelf.C_dView.C_currentLanguage]] finishBack:^(int tag) {
            [self B_cheakUp];
        } animated:NO];
    }
}

-(void)B_downloadZipWith:(NSString *)C_path{
    [A_GameDal B_PostAppLoginReport:_C_appReportApi andParams:@{@"type":@"3",@"report_time":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"package":[NSString B_setSafeString:[[NSBundle mainBundle] bundleIdentifier]],@"device_number":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"standard":[NSString  stringWithFormat:@"%zd",(NSInteger)[[[[NSFileManager defaultManager] attributesOfItemAtPath:[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path error:nil] objectForKey:NSFileCreationDate] timeIntervalSince1970]]} andBack:^(BOOL C_success, id  _Nonnull C_obj) {
        NSLog(@"~~~~~~~~>>>%@",C_obj);
    }];
    [[AppsFlyerLib shared] logEvent:@"Dummy_Trigger_Update" withValues:nil];
    [FIRAnalytics logEventWithName:@"Dummy_Trigger_Update" parameters:nil];
    _C_dView.C_tipsLab.text = _C_dView.C_curLanguageDic[@"80008"][_C_dView.C_currentLanguage];
    __weak A_UpdateController *C_mySelf = self;
    [A_JHHelp B_DownLoadResourcesWithUrl:C_path downLoading:^(id  _Nonnull C_obj) {
//        NSLog(@"obj1->%@",obj);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            C_mySelf.C_dView.C_proress = .15+[C_obj floatValue]*85.0/100.0;
        });
        NSLog(@"obj1->%lf", C_mySelf.C_dView.C_proress);
    } downLoadEnd:^(id  _Nonnull C_obj) {
        NSLog(@"img1 == %@", C_obj);
        NSString *C_zipPath = [NSString B_setSafeString:C_obj];
//        NSString *zipName = [[zipPath lastPathComponent] stringByDeletingPathExtension];
        //获取沙盒doucument路径
        NSString*C_testDirectory = [[A_SandboxHelp B_GetdocumentsDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"/game/"]];
        //删除
        NSLog(@"testDirectory->%@",C_testDirectory);
        [[NSFileManager defaultManager] removeItemAtPath:C_testDirectory error:nil];
        NSFileManager *C_fileManager = [NSFileManager defaultManager];
        [C_fileManager createDirectoryAtPath:C_testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
        C_mySelf.C_dView.C_tipsLab.text = C_mySelf.C_dView.C_curLanguageDic[@"80008"][C_mySelf.C_dView.C_currentLanguage];
        [SSZipArchive unzipFileAtPath:C_zipPath toDestination:C_testDirectory progressHandler:^(NSString * _Nonnull C_entry, unz_file_info C_zipInfo, long C_entryNumber, long C_total) {
            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(entryNumber%10 == 0){
//                    C_mySelf.C_dView.proress = .8+((float)entryNumber/(float)total)*20.0/100.0;
//                }
//            });
            
        } completionHandler:^(NSString * _Nonnull C_path, BOOL C_succeeded, NSError * _Nullable C_error) {
            if (C_succeeded) {
                [A_GameDal B_PostAppReport:C_mySelf.C_appReportApi andParams:@{@"time_diff":[NSString stringWithFormat:@"%zd",[A_JHHelp B_compareDate:[[NSUserDefaults standardUserDefaults] valueForKey:@"game_update_start"] andDate2:[NSDate date]]],@"event":@"8",@"status":@"1",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]]} andBack:^(BOOL success, id  _Nonnull obj) {
                }];
                [[AppsFlyerLib shared] logEvent:@"Dummy_Update_Success" withValues:nil];
                [FIRAnalytics logEventWithName:@"Dummy_Update_Success" parameters:nil];
                [C_mySelf B_startGame:C_mySelf.C_getconfigStr];
            }else{
                [A_GameDal B_PostAppReport:C_mySelf.C_appReportApi andParams:@{@"time_diff":[NSString stringWithFormat:@"%zd",[A_JHHelp B_compareDate:[[NSUserDefaults standardUserDefaults] valueForKey:@"game_update_start"] andDate2:[NSDate date]]],@"event":@"8",@"status":@"0",@"ctime":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]]} andBack:^(BOOL success, id  _Nonnull obj) {
                }];
                [A_promptHelp B_show:[NSString stringWithFormat:@"%@  ",C_mySelf.C_dView.C_curLanguageDic[@"80003"][C_mySelf.C_dView.C_currentLanguage]] view:self.view options:@[[NSString stringWithFormat:@"%@_Reinstall",C_mySelf.C_dView.C_currentLanguage]] finishBack:^(int C_tag) {
                    NSLog(@"`~~~%d",C_tag);
                    [self B_cheakUp];
                } animated:NO];
            }
        }];
    }];
}

- (void)userContentController:(WKUserContentController *)C_userContentController didReceiveScriptMessage:(WKScriptMessage *)C_message {
//    NSLog(@"方法名: %@", message.name);
//    NSLog(@"内容: %@", message.body);
    if ([C_message.name isEqualToString:@"WebGLJsObect"]) {
        NSArray *C_arr = C_message.body;
        BOOL C_ishasEtc = NO;
        for (NSString *C_str in C_arr) {
            if ([C_str isEqualToString:@"WEBGL_compressed_texture_etc1"]) {
                C_ishasEtc = YES;
                break;
            }
            if ([C_str isEqualToString:@"WEBKIT_WEBGL_compressed_texture_etc1"]) {
                C_ishasEtc = YES;
                break;
            }
        }
        [[NSUserDefaults standardUserDefaults] setBool:C_ishasEtc forKey:@"ishasEtc"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    if (C_message.body == nil) {
      return;
    }
    
    if ([C_message.name isEqualToString:@"JsToNative"]) {
    //这个是传过来的参数
        NSLog(@"%@",C_message.body);
        [self B_jsToNative:C_message.body];
    }
}


-(WKWebView *)C_httpswkView{
    if (!_C_httpswkView) {

        WKWebViewConfiguration *C_configuration = [[WKWebViewConfiguration alloc] init];
        C_configuration.allowsInlineMediaPlayback = YES;
        C_configuration.mediaTypesRequiringUserActionForPlayback = false;
        NSString *C_sandBox = [NSString stringWithFormat:@"%@/platform/ZBPlus-iOS.txt",[A_SandboxHelp B_GetdocumentsDirectory]];
        NSString *C_str = [NSString stringWithContentsOfFile:C_sandBox encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"str->%@",C_str);
            //注入时机是在webview加载状态WKUserScriptInjectionTimeAtDocumentStart、WKUserScriptInjectionTimeAtDocumentEnd
           WKUserScript *C_userScript = [[WKUserScript alloc] initWithSource:C_str injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
           [C_configuration.userContentController addUserScript:C_userScript];

        [C_configuration.userContentController addScriptMessageHandler:self name:@"JsToNative"];
        _C_httpswkView = [[WKWebView alloc] initWithFrame:self.view.bounds
                                        configuration:C_configuration];
        _C_httpswkView.navigationDelegate = self;
        _C_httpswkView.UIDelegate = self;
        _C_httpswkView.hidden = YES;
        [self.view addSubview:_C_httpswkView];
    }
    return _C_httpswkView;
}

-(WKWebView *)C_wkView{
    if (!_C_wkView) {

        WKWebViewConfiguration *C_configuration = [[WKWebViewConfiguration alloc] init];
        C_configuration.allowsInlineMediaPlayback = YES;
        C_configuration.mediaTypesRequiringUserActionForPlayback = false;
        NSString *C_sandBox = [NSString stringWithFormat:@"%@/platform/ZBPlus-iOS.txt",[A_SandboxHelp B_GetdocumentsDirectory]];
        NSString *C_str = [NSString stringWithContentsOfFile:C_sandBox encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"str->%@",C_str);
           WKUserScript *C_userScript = [[WKUserScript alloc] initWithSource:C_str injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
           [C_configuration.userContentController addUserScript:C_userScript];

        [C_configuration.userContentController addScriptMessageHandler:self name:@"JsToNative"];
        _C_wkView = [[WKWebView alloc] initWithFrame:CGRectZero
                                        configuration:C_configuration];
        _C_wkView.navigationDelegate = self;
        _C_wkView.UIDelegate = self;
        _C_wkView.hidden = YES;
        _C_wkView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:_C_wkView];
        if(@available(iOS 11.0, *)) {
            _C_wkView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _C_wkView;
}

- (void)B_loadLocalRequest:(NSString *)C_path{
    [self.C_wkView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost:%ld/%@", [[A_LocalWebServerManager B_sharedInstance] port],C_path]] cachePolicy:1 timeoutInterval:20]];
//    [self.C_wkView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://game1.gameyibang.cn/game/index.html?id%3D1001%26uid%3D5413%26token%3Df00Cpr21sdmRfjRjZRPfl1q4d4%26cdn%3Dhttps%3A%2F%2Fcdn1.gameyibang.cn%26musicSwitch%3Dtrue%26lang%3Dcn%26domainName%3Dgame1.gameyibang.cn%26type%3D1%26gl%3D1001%2C1101%2C1201"] cachePolicy:1 timeoutInterval:20]];
}

-(A_UpdateView *)C_dView{
    if(!_C_dView){
        _C_dView = [A_UpdateView new];
    }
    return _C_dView;
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    _C_wkView.frame = CGRectMake(0, 0, WIDTHDiv, HEIGHTDiv);
    _C_dView.frame = CGRectMake(0, 0, WIDTHDiv, HEIGHTDiv);
    UIWindow *C_window = [UIApplication sharedApplication].keyWindow;
    UIView *C_img_view = [C_window viewWithTag:765];
    C_img_view.frame = CGRectMake(0, 0, 3*WIDTHDiv, HEIGHTDiv);
}



#pragma mark - WKNavigationDelegate
-(void)webView:(WKWebView *)C_webView
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)C_challenge
                completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition C_disposition, NSURLCredential * _Nullable C_credential))C_completionHandler {
    
    if ([C_challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *C_card = [[NSURLCredential alloc] initWithTrust:C_challenge.protectionSpace.serverTrust];
        C_completionHandler(NSURLSessionAuthChallengeUseCredential, C_card);
    }
}

#pragma mark - UIDelegate
-                       (void)webView:(WKWebView *)C_webView
   runJavaScriptAlertPanelWithMessage:(NSString *)C_message
                     initiatedByFrame:(WKFrameInfo *)C_frame
                    completionHandler:(void (^)(void))C_completionHandler {
    
    NSString *C_alertTitle = @"温馨提示";
    UIAlertController *C_alertController = [UIAlertController alertControllerWithTitle:C_alertTitle
                                                                             message:C_message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [C_alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull C_action) {
        C_completionHandler();
                                                      }]];
    [self presentViewController:C_alertController animated:YES completion:nil];
}

// 页面开始加载时调用
- (void)webView:(WKWebView *)C_webView didStartProvisionalNavigation:(WKNavigation *)C_navigation {

}
// 页面加载失败时调用
- (void)webView:(WKWebView *)C_webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)C_navigation withError:(NSError *)C_error {
    [self B_toJsonc:E_WKWEBVIEW B_f:E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"error"}];
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)C_webView didCommitNavigation:(WKNavigation *)C_navigation {
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)C_webView didFinishNavigation:(WKNavigation *)C_navigation {
    if(![C_webView.URL.absoluteString isEqualToString:@"about:blank"]){
        [self B_toJsonc:E_WKWEBVIEW B_f:E_EVENTLISTENER B_d:@{@"id":[NSString B_setSafeString:_C_wk_id],@"event":@"loaded"}];
    }
}
//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self B_toJsonc:E_WKWEBVIEW B_f:E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"error"}];
}
// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)C_webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)C_navigation {
}


/** 程序被杀死 */
- (void)applicationWillTerminate {
    NSLog(@"applicationWillTerminate");
    [A_GameDal B_PostAppLoginReport:_C_appReportApi andParams:@{@"type":@"1",@"report_time":[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]],@"package":[NSString B_setSafeString:[[NSBundle mainBundle] bundleIdentifier]],@"device_number":[[[UIDevice currentDevice] identifierForVendor] UUIDString],@"standard":[NSString  stringWithFormat:@"%zd",(NSInteger)[[[[NSFileManager defaultManager] attributesOfItemAtPath:[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject].path error:nil] objectForKey:NSFileCreationDate] timeIntervalSince1970]]} andBack:^(BOOL C_success, id  _Nonnull C_obj) {
        
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:@"EAGView"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                       name:UIDeviceOrientationDidChangeNotification
                                                     object:nil
        ];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:@"CT_NativeToJs"];

}

@end
