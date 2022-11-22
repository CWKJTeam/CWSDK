//
//  UpdateView.m
//  vpower(i_1)
//
//  Created by 叶建辉 on 2021/12/8.
//  Copyright © 2021 egret. All rights reserved.
//

#import "A_UpdateView.h"

@interface A_UpdateView()
@property(nonatomic,strong)UIImageView *C_Bgimg;
@property(nonatomic,strong)UIView *C_proressView;

@property(nonatomic,weak)UILabel *C_proressLab;
@property(nonatomic,strong)A_JHProgressView *C_pView;
@end

@implementation A_UpdateView

-(A_JHProgressView *)C_pView{
    if (!_C_pView) {
        _C_pView = [[A_JHProgressView alloc]initWithFrame:CGRectMake(WIDTHDiv*.2, HEIGHTDiv*.5, WIDTHDiv*.6, WIDTHDiv*.6*.0517)];
        
//        _C_pView.layer.masksToBounds = YES;
    }
    return _C_pView;
}
-(UIView *)C_proressView{
    if (!_C_proressView) {
        _C_proressView = [UIView new];
        [_C_proressView addSubview:self.C_pView];
        _C_proressView.backgroundColor = [UIColor clearColor];
        NSArray *C_imgStrs = @[@"loadingBG",@"loading",@"spray",@"spray_1"];
        NSString *C_curVersion = [NSString string];
        //沙盒版本文件地址
        NSString *C_sandBox = [NSString stringWithFormat:@"%@/game/resource/global.json",[A_SandboxHelp B_GetdocumentsDirectory]];
        //沙盒文件版本号
        if ([A_SandboxHelp B_isExistsAtPath:C_sandBox]) {
//            NSLog(@"sandBox~~>>%@",sandBox);
            C_curVersion = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:C_sandBox] options:kNilOptions error:nil][@"version"];
        }else{
            //项目版本文件地址
            NSString *project = [NSString stringWithFormat:@"%@/game/resource/global.json",[[NSBundle mainBundle]resourcePath]];
            //项目文件版本号
            if ([A_SandboxHelp B_isExistsAtPath:project]) {
//                NSLog(@"project~~>>%@",project);
                C_curVersion = [NSJSONSerialization JSONObjectWithData:[[NSData alloc] initWithContentsOfFile:project] options:kNilOptions error:nil][@"version"];
            }
        }
        
        NSArray *C_labStrs = @[@"游戏更新中",@"0%",C_curVersion];
        for (int C_i = 0; C_i < 4; C_i++) {
            UIImageView *C_img = [[UIImageView alloc]initWithImage:[UIImage B_imageNameds:C_imgStrs[C_i]]];
            C_img.tag = 1000+C_i;
            if (C_i>1) {
                [_C_proressView addSubview:C_img];
            }
            
            if (C_i != 3) {
                UILabel *C_lab = [UILabel new];
                C_lab.tag = 2000+C_i;
                C_lab.textColor = [UIColor whiteColor];
                
                switch (C_i) {
                    case 0:
                        C_lab.textAlignment = NSTextAlignmentCenter;
                        C_lab.font = [UIFont boldSystemFontOfSize:self.C_width*.7*.0378*.8];
                        _C_tipsLab = C_lab;
                        break;
                    case 1:
                        C_lab.font = [UIFont systemFontOfSize:self.C_width*.7*.0378*.684];
                        _C_proressLab = C_lab;
                        break;
                    case 2:
                        C_lab.font = [UIFont systemFontOfSize:self.C_width*.7*.0378*.5];
                        _C_verLab = C_lab;
                        break;
                }
                C_lab.text = C_labStrs[C_i];
                [_C_proressView addSubview:C_lab];
            }
        }
    }
    return _C_proressView;
}

-(UIImageView *)C_Bgimg{
    if(!_C_Bgimg){
        _C_Bgimg = [UIImageView new];
        _C_Bgimg.image = [UIImage B_imageNameds:@"load_bg.jpg"];
        UIImageView *C_logoimg = [UIImageView new];
        C_logoimg.image = [UIImage B_imageNameds:@"logo"];
        C_logoimg.tag = 1020;
        [_C_Bgimg addSubview:C_logoimg];
    }
    return _C_Bgimg;
}

- (instancetype)initWithFrame:(CGRect)C_frame
{
    self = [super initWithFrame:C_frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.C_Bgimg];
        [self addSubview:self.C_proressView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    _C_Bgimg.frame = CGRectMake(0, 0, HEIGHTDiv/.462, HEIGHTDiv);
    _C_Bgimg.center = self.center;
    UIImageView *C_logoimg = [_C_Bgimg viewWithTag:1020];
    C_logoimg.frame = CGRectMake((_C_Bgimg.C_width-_C_Bgimg.C_height*.675/.857)/2, (_C_Bgimg.C_height-_C_Bgimg.C_height*.675)*.15, _C_Bgimg.C_height*.675/.857, _C_Bgimg.C_height*.675);
    _C_proressView.frame = CGRectMake(0, HEIGHTDiv*.8, self.C_width, HEIGHTDiv*.2);
    
    _C_pView.frame = CGRectMake(self.C_width*.2, (HEIGHTDiv*.2-self.C_width*.6*.0517)/2, self.C_width*.6, self.C_width*.6*.0517);
    [_C_pView setNeedsLayout];
    for (int C_i = 0; C_i < 4; C_i++) {
        UIImageView *C_img = [_C_proressView viewWithTag:1000+C_i];
        switch (C_i) {
            case 0:
                C_img.frame = CGRectMake(self.C_width*.15, (HEIGHTDiv*.2-self.C_width*.7*.0378)/2, self.C_width*.7, self.C_width*.7*.0378);
                break;
            case 1:
                C_img.frame = CGRectMake((self.C_width-self.C_width*.7*.987)*.495, (HEIGHTDiv*.2-self.C_width*.7*.0378*.684)*.485, self.C_width*.7*.987, self.C_width*.7*.0378*.684);
                break;
            case 2:
                C_img.frame = CGRectMake(self.C_width*.14, (HEIGHTDiv*.2-self.C_width*.7*.0378)*.435, self.C_width*.7*.0378/.348, self.C_width*.7*.0378);
                break;
            case 3:
                C_img.frame = CGRectMake(self.C_width-self.C_width*.145-self.C_width*.7*.0378/.348, (HEIGHTDiv*.2-self.C_width*.7*.0378)*.435, self.C_width*.7*.0378/.348, self.C_width*.7*.0378);
                break;
        }
        
        if (C_i != 3) {
            UILabel *C_lab = [_C_proressView viewWithTag:2000+C_i];
            switch (C_i) {
                case 0:
                    C_lab.frame = CGRectMake(self.C_width*.2, -HEIGHTDiv*.05, self.C_width*.6, HEIGHTDiv*.1);
                    C_lab.layer.shadowColor = [UIColor blackColor].CGColor;
                    C_lab.layer.shadowOffset = CGSizeMake(0, 0);
                    C_lab.layer.shadowOpacity = 2;
                    C_lab.textAlignment = NSTextAlignmentCenter;
                    C_lab.font = [UIFont boldSystemFontOfSize:self.C_width*.7*.0378*.8];
                    break;
                case 1:
                    C_lab.font = [UIFont systemFontOfSize:self.C_width*.7*.0378*.684];
                    C_lab.layer.shadowColor = [UIColor blackColor].CGColor;
                    C_lab.layer.shadowOffset = CGSizeMake(10, 10);
                    C_lab.layer.shadowOpacity = 1;
                    C_lab.frame = CGRectMake(self.C_width*.45, (HEIGHTDiv*.2-self.C_width*.7*.0378)*.48, self.C_width*.1, self.C_width*.7*.0378);
                    break;
                case 2:
                {
                    C_lab.font = [UIFont systemFontOfSize:self.C_width*.7*.0378*.5];
                    NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:self.C_width*.7*.0378*.5]};
                    CGSize size=[C_lab.text sizeWithAttributes:attrs];
                    C_lab.frame = CGRectMake(self.C_width-size.width-self.C_width*.06, HEIGHTDiv*.2-self.C_width*.7*.0378*.75, size.width, self.C_width*.7*.0378*.52);
                }
                    break;
            }
        }
    }
    
    
}

-(void)setC_proress:(float)C_proress{
    _C_proress = C_proress;
//    NSLog(@"_C_proress->%lf ", _C_proress);
    
    _C_proressLab.text = [NSString stringWithFormat:@"%.2lf%%",_C_proress*100];
    _C_pView.progress = _C_proress;
}

@end
