//
//  JHProgressView.m
//  vpower(i_1)
//
//  Created by 叶建辉 on 2021/12/15.
//  Copyright © 2021 egret. All rights reserved.
//

#import "A_JHProgressView.h"
#import "UIImage+A_setImageStrName.h"
#import "UIView+A_Frame.h"
@interface A_JHProgressView ()

@property(nonatomic,weak)UIView *C_GifView;
@end

@implementation A_JHProgressView

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor clearColor];
        _C_trackView =[[UIImageView alloc] initWithFrame:CGRectMake (0, 0, frame.size.width, frame.size.height)];
//        _trackView.backgroundColor = [UIColor colorWithRed:33/255.0 green:33/255.0 blue:33/255.0 alpha:1];
        [_C_trackView setImage:[UIImage B_imageNameds:@"loadingBG"]];
//        _trackView.clipsToBounds = YES;
//        _trackView.layer.masksToBounds = NO;
        [self addSubview:_C_trackView];
        
        
        UIView *bgv =[[UIView alloc] initWithFrame:CGRectMake (0, 0,frame.size.width,frame.size.height)];
//        bgv.backgroundColor = [UIColor redColor];
//        bgv.clipsToBounds = YES;
        bgv.tag = 99;
        bgv.layer.masksToBounds = YES;
        bgv.layer.cornerRadius = bgv.C_height/2;
        [_C_trackView addSubview:bgv];
        
        _C_progressView = [[UIImageView alloc]
        initWithFrame:CGRectMake (0 - frame.size.width, 0, frame.size.width, frame.size.height)];
        [_C_progressView setImage:[UIImage B_imageNameds:@"loading"]];
//        _progressView.backgroundColor = [UIColor colorWithRed:210/255.0 green:164/255.0 blue:59/255.0 alpha:1];
        [bgv addSubview:_C_progressView];
        
    }
    return self;
}

-(void)layoutSubviews{
    _C_trackView.frame =CGRectMake (0, 0, self.C_width, self.C_height);
    UIView *bgv =[_C_trackView viewWithTag:99];
    bgv.frame = CGRectMake (0, 0,self.C_width,self.C_height);
    bgv.layer.masksToBounds = YES;
    bgv.layer.cornerRadius = bgv.C_height/2;
    
    _C_progressView.frame = CGRectMake (0 - self.C_width, 0, self.C_width, self.C_height);
     
}

- (void)setProgress:(CGFloat)progress{
    _C_targetProgress = progress;
    [self changeProgressViewFrame];
}

- (void)changeProgressViewFrame{
    _C_progressView.frame = CGRectMake ((self.C_width * _C_targetProgress) - self.C_width,0, self.C_width, self.C_height);
//    _progressView.layer.masksToBounds = YES;
//    _progressView.layer.cornerRadius = _progressView.C_height/2;
//    _GifView = [loadGif show:_trackView imgStr:@"" repeat:YES speed:3 imgCount:3 rect:CGRectMake(_progressView.C_right-self.C_height/.346*.913*.58, -(self.C_height/.346-self.C_height)/2, self.C_height/.346*.913, self.C_height/.346)];
}
@end
