//
//  JHProgressView.h
//  vpower(i_1)
//
//  Created by 叶建辉 on 2021/12/15.
//  Copyright © 2021 egret. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface A_JHProgressView : UIView
// 进度条背景图片

@property (retain, nonatomic) UIImageView *C_trackView;

// 进图条填充图片

@property (retain, nonatomic) UIImageView *C_progressView;

//进度

@property (nonatomic) CGFloat C_targetProgress;

//设置进度条的值

- (void)setProgress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
