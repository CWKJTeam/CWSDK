//
//  LocalWebServerManager.h
//  LocalWebServer
//
//  Created by Smallfan on 23/08/2017.
//  Copyright © 2017 Smallfan. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^webBack)();
@interface A_LocalWebServerManager : NSObject

@property (nonatomic, assign, readonly) NSUInteger C_port;

+ (instancetype)B_sharedInstance;

- (void)B_start:(NSString *)C_webLocalPath andBack:(webBack)C_back;
- (void)B_stop;

- (BOOL)B_isStart;

@end
