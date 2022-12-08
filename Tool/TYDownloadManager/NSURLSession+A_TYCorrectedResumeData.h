//
//  NSURLSession+TYCorrectedResumeData.h
//  TYDLManagerDemo
//
//  Created by tanyang on 2016/10/7.
//  Copyright © 2016年 tany. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (A_TYCorrectedResumeData)

- (NSURLSessionDownloadTask *)B_DLTaskWithCorrectResumeData:(NSData *)C_resumeData;

@end
