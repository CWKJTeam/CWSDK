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
    HTTPServer *_httpServer;
}
@end

@implementation A_LocalWebServerManager

+ (instancetype)B_sharedInstance {
    static A_LocalWebServerManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[A_LocalWebServerManager alloc] init];
    });
    return _sharedInstance;
}

- (BOOL)B_isStart{
    if (_httpServer && [_httpServer isRunning]) {
        return YES;
    }
    return NO;
}

- (void)B_start:(NSString *)webLocalPath andBack:(webBack)back{
    
    _port = 13131;
    
    if (!_httpServer) {
        _httpServer = [[HTTPServer alloc] init];
//        [_httpServer setConnectionClass:[MyHTTPConnection class]];
        [_httpServer setType:@"_http._tcp."];
        [_httpServer setPort:_port];
//        NSString * webLocalPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Resource"];
        [_httpServer setDocumentRoot:webLocalPath];
        
        NSLog(@"Setting document root: %@", webLocalPath);
        
    }
    
    if (_httpServer && ![_httpServer isRunning]) {
        NSError *error;
        if([_httpServer start:&error]) {
            NSLog(@"start server success in port %d %@", [_httpServer listeningPort], [_httpServer publishedName]);
            back();
        } else {
            NSLog(@"启动失败");
        }
    }
    
}

- (void)B_stop {
    if (_httpServer && [_httpServer isRunning]) {
        [_httpServer stop];
    }
}

@end
