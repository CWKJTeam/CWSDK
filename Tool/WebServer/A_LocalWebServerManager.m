//
//  LocalWebServerManager.m
//  LocalWebServer
//
//  Created by Smallfan on 23/08/2017.
//  Copyright © 2017 Smallfan. All rights reserved.
//

#import "A_LocalWebServerManager.h"

#import "HTTPServer.h"
#import "A_MyHTTPConnection.h"

@interface A_LocalWebServerManager ()
{
    HTTPServer *_C_httpServer;
}
@end

@implementation A_LocalWebServerManager

+ (instancetype)B_sharedInstance {
    static A_LocalWebServerManager *_C_sharedInstance = nil;
    static dispatch_once_t C_onceToken;
    dispatch_once(&C_onceToken, ^{
        _C_sharedInstance = [[A_LocalWebServerManager alloc] init];
    });
    return _C_sharedInstance;
}

- (BOOL)B_isStart{
    if (_C_httpServer && [_C_httpServer isRunning]) {
        return YES;
    }
    return NO;
}

- (void)B_start:(NSString *)C_webLocalPath andBack:(webBack)C_back{
    
    _C_port = 13131;
    
    if (!_C_httpServer) {
        _C_httpServer = [[HTTPServer alloc] init];
//        [_httpServer setConnectionClass:[MyHTTPConnection class]];
        [_C_httpServer setType:@"_http._tcp."];
        [_C_httpServer setPort:_C_port];
//        NSString * webLocalPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Resource"];
        [_C_httpServer setDocumentRoot:C_webLocalPath];
        
        NSLog(@"Setting document root: %@", C_webLocalPath);
        
    }
    
    if (_C_httpServer && ![_C_httpServer isRunning]) {
        NSError *C_error;
        if([_C_httpServer start:&C_error]) {
            NSLog(@"start server success in port %d %@", [_C_httpServer listeningPort], [_C_httpServer publishedName]);
            C_back();
        } else {
            NSLog(@"启动失败");
        }
    }
    
}

- (void)B_stop {
    if (_C_httpServer && [_C_httpServer isRunning]) {
        [_C_httpServer stop];
    }
}

@end
