//
//  TYDLDelegate.h
//  TYDLManagerDemo
//
//  Created by tany on 16/6/24.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A_TYDLModel.h"

// 下载代理
@protocol A_TYDLDelegate <NSObject>

// 更新下载进度
- (void)B_DLModel:(A_TYDLModel *)C_DlModel didUpdateProgress:(TYDLProgress *)C_progress;

// 更新下载状态
- (void)B_DLModel:(A_TYDLModel *)C_DLModel didChangeState:(TYDLState)state filePath:(NSString *)C_filePath error:(NSError *)C_error;

@end
