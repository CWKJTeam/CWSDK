//
//  CustomerController.m
//  (i_1)VPower
//
//  Created by 叶建辉 on 2022/4/9.
//  Copyright © 2022 egret. All rights reserved.
//

#import "A_CustomerController.h"
#import <WebKit/WebKit.h>
#import "AppDelegate.h"

@interface A_QYWeakScriptMessageHandlerDelegate : NSObject<WKScriptMessageHandler>

@property (nonatomic, weak) id<WKScriptMessageHandler> C_scriptDelegate;
- (instancetype)B_initWithDelegate:(id<WKScriptMessageHandler>)C_scriptDelegate;

@end

@implementation A_QYWeakScriptMessageHandlerDelegate
- (instancetype)B_initWithDelegate:(id<WKScriptMessageHandler>)C_scriptDelegate {
    if (self == [super init]) {
        _C_scriptDelegate = C_scriptDelegate;
    }
    return self;
}

- (void)userContentController:(WKUserContentController *)C_userContentController didReceiveScriptMessage:(WKScriptMessage *)C_message {
    [self.C_scriptDelegate userContentController:C_userContentController didReceiveScriptMessage:C_message];
}
@end

@interface A_CustomerController ()<WKUIDelegate,WKNavigationDelegate,WKScriptMessageHandler>
@property(nonatomic,strong)WKWebView *C_wkWebView;
@property(nonatomic,assign)BOOL C_isClose;
@end

@implementation A_CustomerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(B_loadLocalRequest) userInfo:nil repeats:NO];
}

-(void)setC_Style:(NSString *)C_style{
    _C_style = C_style;
    if ([_C_style isEqualToString:@"close"]) {
        _C_isClose = YES;
    }else{
        _C_isClose = NO;
    }
}

-(WKWebView *)C_wkWebView{
    if (!_C_wkWebView) {

        WKWebViewConfiguration *C_configuration = [[WKWebViewConfiguration alloc] init];
        C_configuration.allowsInlineMediaPlayback = YES;
        C_configuration.mediaTypesRequiringUserActionForPlayback = YES;
        NSString *C_sandBox = [NSString stringWithFormat:@"%@/platform/ZBPlus-iOS.txt",[A_SandboxHelp B_GetdocumentsDirectory]];
        NSString *C_str = [NSString stringWithContentsOfFile:C_sandBox encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"str->%@",C_str);
           WKUserScript *C_userScript = [[WKUserScript alloc] initWithSource:C_str injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
           [C_configuration.userContentController addUserScript:C_userScript];

//        [configuration.userContentController addScriptMessageHandler:self name:@"JsToNative"];
        
        [C_configuration.userContentController addScriptMessageHandler:[[A_QYWeakScriptMessageHandlerDelegate alloc] B_initWithDelegate:self] name:@"JsToNative"];
        _C_wkWebView = [[WKWebView alloc] initWithFrame:_C_isClose?CGRectMake(0, 40, C_WIDTHDiv, C_HEIGHTDiv-40):CGRectMake(0, 0, C_WIDTHDiv, C_HEIGHTDiv)
                                        configuration:C_configuration];
        _C_wkWebView.navigationDelegate = self;
        _C_wkWebView.UIDelegate = self;
//        _wkWebView.hidden = YES;
        _C_wkWebView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:_C_wkWebView];
        if (_C_isClose) {
            UIButton *C_back = [UIButton new];
            C_back.tag = 10087;
            [C_back setImage:[UIImage B_imageNameds:@"game_back"] forState:UIControlStateNormal];
            [C_back addTarget:self action:@selector(B_backClick) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:C_back];
            UILabel *C_lab = [UILabel new];
            C_lab.tag = 10086;
            C_lab.textAlignment = NSTextAlignmentCenter;
            C_lab.textColor = [UIColor blackColor];
            [self.view addSubview:C_lab];
            C_back.frame = CGRectMake(10, 5, 30, 30);
            C_lab.frame = CGRectMake(0, 5, C_WIDTHDiv, 30);
            C_lab.font = [UIFont boldSystemFontOfSize:22];
        }
    }
    return _C_wkWebView;
}

-(void)B_backClick{
    [self dismissViewControllerAnimated:NO completion:^{
    }];
    [self B_toJsonc:C_E_WKWEBVIEW B_f:C_E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"close"}];
}

- (void)B_loadLocalRequest{
    [self.C_wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_C_webUrl] cachePolicy:1 timeoutInterval:20]];
//    NSLog(@"wkWebView--%@",self.wkWebView);
}

- (void)userContentController:(WKUserContentController *)C_userContentController didReceiveScriptMessage:(WKScriptMessage *)C_message {
    NSLog(@"方法名: %@", C_message.name);
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
//        [self jsToNative:message.body];
        NSDictionary *C_dic = [A_JHHelp B_dictionaryWithJsonString:C_message.body];
        if([[NSString B_setSafeString:C_dic[C_E_FUNCTION]] isEqualToString:@"hide"]){
            AppDelegate *C_appd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            C_appd.isverScreen = NO;
            
            UIImage *C_img_turn = [self B_TDScreenCapturesnapshotView:self.view];
            UIDeviceOrientation C_ot = _C_duration;
            
            if (_C_duration == UIDeviceOrientationLandscapeLeft) {
                C_ot = UIDeviceOrientationLandscapeLeft;
            }else if (_C_duration == UIDeviceOrientationLandscapeRight) {
                C_ot = UIDeviceOrientationLandscapeRight;
            }else{
                C_ot = UIDeviceOrientationLandscapeLeft;
            }
       
            
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:C_ot] forKey:@"orientation"];

            if (_C_isShuping) {
                UIWindow *C_window = [UIApplication sharedApplication].keyWindow;
                UIImageView *C_img_ = [UIImageView new];
                C_img_.tag = 567;
                C_img_.image = C_img_turn;
                C_img_.transform = CGAffineTransformMakeRotation(M_PI*1.5);
                
                [C_window addSubview:C_img_];
                [self.view setNeedsLayout];
                [NSTimer scheduledTimerWithTimeInterval:0.35f repeats:NO block:^(NSTimer * _Nonnull C_timer) {
                                [self dismissViewControllerAnimated:NO completion:^{
                                    [C_img_ removeFromSuperview];
                                }];
                }];
            }else{
                [self dismissViewControllerAnimated:NO completion:^{
                }];
            }
            [self B_toJsonc:C_E_WKWEBVIEW B_f:C_E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"hide"}];
        }
        else if([[NSString B_setSafeString:C_dic[C_E_FUNCTION]] isEqualToString:@"close"]){
            AppDelegate *C_appd = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            C_appd.isverScreen = NO;
            
            UIImage *C_img_turn = [self B_TDScreenCapturesnapshotView:self.view];
            UIDeviceOrientation ot = _C_duration;
            
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:ot] forKey:@"orientation"];

            if (_C_isShuping) {
                UIWindow *C_window = [UIApplication sharedApplication].keyWindow;
                UIImageView *C_img_ = [UIImageView new];
                C_img_.tag = 567;
                C_img_.image = C_img_turn;
                C_img_.transform = CGAffineTransformMakeRotation(M_PI*1.5);
                
                [C_window addSubview:C_img_];
                [self.view setNeedsLayout];
                [NSTimer scheduledTimerWithTimeInterval:0.35f repeats:NO block:^(NSTimer * _Nonnull C_timer) {
                                [self dismissViewControllerAnimated:NO completion:^{
                                    [C_img_ removeFromSuperview];
                                }];
                }];
            }else{
                [self dismissViewControllerAnimated:NO completion:^{
                }];
            }
            
            [self B_toJsonc:C_E_WKWEBVIEW B_f:C_E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"close"}];
        }
    }
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    UIWindow *C_window = [UIApplication sharedApplication].keyWindow;
    _C_wkWebView.frame = _C_isClose?CGRectMake(0, 40, C_WIDTHDiv, C_HEIGHTDiv-40):CGRectMake(0, 0, C_WIDTHDiv, C_HEIGHTDiv);
    
    UIImageView *C_img_ = [C_window viewWithTag:567];
    C_img_.frame = CGRectMake(0, 0, C_WIDTHDiv,C_HEIGHTDiv);
    
    
    UIButton *C_back = [self.view viewWithTag:10087];
    C_back.frame = CGRectMake(10, 5, 30, 30);
    UILabel *C_lab = [self.view viewWithTag:10086];
    C_lab.frame = CGRectMake(0, 5, C_WIDTHDiv, 30);
}

#pragma mark - WKNavigationDelegate
-(void)webView:(WKWebView *)C_webView
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)C_challenge
                completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential * _Nullable credential))C_completionHandler {
    
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
    [self B_toJsonc:C_E_WKWEBVIEW B_f:C_E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"error"}];
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)C_webView didCommitNavigation:(WKNavigation *)C_navigation {
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)C_webView didFinishNavigation:(WKNavigation *)C_navigation {
    
    UILabel *C_lab = [self.view viewWithTag:10086];
    C_lab.text = C_webView.title;
    
    if(![C_webView.URL.absoluteString isEqualToString:@"about:blank"]){
        [self B_toJsonc:C_E_WKWEBVIEW B_f:C_E_EVENTLISTENER B_d:@{@"id":[NSString B_setSafeString:_C_wk_id],@"event":@"loaded"}];
    }
    

}
//提交发生错误时调用
- (void)webView:(WKWebView *)C_webView didFailNavigation:(WKNavigation *)C_navigation withError:(NSError *)C_error {
    [self B_toJsonc:C_E_WKWEBVIEW B_f:C_E_EVENTLISTENER B_d:@{@"id":_C_wk_id,@"event":@"error"}];
}
// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)C_webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)C_navigation {
}

-(void)B_toJsonc:(NSString *)C_c B_f:(NSString *)C_f B_d:(NSDictionary *)C_d{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"CT_NativeToJs" object:nil userInfo:@{@"class":C_c,@"function":C_f, @"args":C_d}];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:@"EAGView"];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                       name:UIDeviceOrientationDidChangeNotification
                                                     object:nil
        ];
    NSLog(@"ct dealloc");
    [_C_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"JsToNative"];

}

- (UIImage *)B_TDScreenCapturesnapshotView:(UIView *)C_view
{
    // 判断是否为retina屏, 即retina屏绘图时有放大因子
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]){
        UIGraphicsBeginImageContextWithOptions(C_view.bounds.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(C_view.bounds.size);
    }
    
    [C_view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *C_image = UIGraphicsGetImageFromCurrentImageContext();
      
    UIGraphicsEndImageContext();
    return C_image;
}

@end





