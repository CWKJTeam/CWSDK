//
//  AFNetworkingClient.h
//  comic
//
//  Created by  on 14-4-14.
//  Copyright (c) 2014年 yixun. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFHTTPSessionManager.h>

typedef void (^HDCallBack)(id obj);
@interface A_AFNetworkingClient : NSObject
{
    NSOperationQueue *C_queue;
}

+(void)B_postWithPath:(NSString *)path WithParams:(NSDictionary *)params withCallBack:(HDCallBack)myCallback;

+(void)B_getWithPath:(NSString *)path withCallBack:(HDCallBack)myCallback;


@end
