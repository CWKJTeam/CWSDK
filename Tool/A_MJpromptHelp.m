//
//  promptHelp.m
//  Unity-iPhone
//
//  Created by QPX on 2019/5/15.
//

#import "A_MJpromptHelp.h"
#import "A_JHLabel.h"
#import "UIView+A_Frame.h"
#import "A_Tool.h"

@interface A_MJpromptView : UIView



- (instancetype)initWithTipString:(NSString *)C_TipString image:(id)C_obj options:(NSArray *)C_options type:(int)C_type animated:(BOOL)C_animated;

@property(nonatomic,assign)int C_type;

@property (nonatomic, copy) void(^block)(int tag);

@property(nonatomic,strong)NSString *C_tipStr;

@property(nonatomic,strong)id C_image;

@property(nonatomic,strong)NSArray *C_options;

@end

@interface A_MJpromptView ()

@property(nonatomic,strong)A_JHLabel *C_tipsLab;

@property(nonatomic,strong)UIView *C_bgView;

@property(nonatomic,strong)UIImageView *C_headImg;

@property(nonatomic,assign)int C_animaindex;

@property(nonatomic,assign)BOOL C_animated;

@end

@implementation A_MJpromptView

-(UIFont *)B_getFontWithUnderSix:(float)C_underSix{
    
    CGFloat C_proportion = C_SIX_DIV;
    
    if (C_IS_IPAD) {
        C_proportion = (C_WIDTHDiv-C_IPAD_BETWEENS)/375;
    }
    
    return [UIFont systemFontOfSize:C_underSix*C_proportion];
}

-(UIFont *)B_getboldFontWithUnderSix:(float)C_underSix{
    
    CGFloat C_proportion = C_SIX_DIV;
    
    if (C_IS_IPAD) {
        C_proportion = (C_WIDTHDiv-C_IPAD_BETWEENS)/375;
    }
    
    return [UIFont boldSystemFontOfSize:C_underSix*C_proportion];
}


-(UILabel *)C_tipsLab{
    if(!_C_tipsLab){
        _C_tipsLab = [A_JHLabel new];
        _C_tipsLab.font = [self B_getFontWithUnderSix:C_IS_IPAD?12:16];
        _C_tipsLab.textColor = [UIColor colorWithWhite:.2 alpha:1];
        _C_tipsLab.textAlignment = NSTextAlignmentCenter;
        _C_tipsLab.numberOfLines = 0;
    }
    return _C_tipsLab;
}

-(UIView *)C_bgView{
    if(!_C_bgView){
        _C_bgView = [UIView new];
        
    }
    return _C_bgView;
}

-(UIImageView *)C_headImg{
    if(!_C_headImg){
        _C_headImg = [UIImageView new];
        
    }
    return _C_headImg;
}

- (instancetype)B_initWithTipString:(NSString *)C_TipString image:(id)C_obj options:(NSArray *)C_options type:(int)C_type animated:(BOOL)C_animated
{
    if (self == [self init]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
        float c;
        float d;
        if(C_WIDTHDiv>C_HEIGHTDiv){
            c = C_WIDTHDiv;
            d = C_HEIGHTDiv;
        }else{
            c = C_HEIGHTDiv;
            d = C_WIDTHDiv;
        }
        
        self.frame = CGRectMake(0, 0, C_WIDTHDiv, C_HEIGHTDiv);
        _C_animaindex = 0;
        _C_type = C_type;
        _C_tipStr = C_TipString;
        _C_image = C_obj;
        _C_options = C_options;
        _C_animated = C_animated;
        UIButton *clearbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, C_WIDTHDiv, C_HEIGHTDiv)];
        clearbtn.tag = 1098;
        [clearbtn addTarget:self action:@selector(B_removeselfBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearbtn];
        [self addSubview:self.C_bgView];
        if(_C_type == 1){
            _C_bgView.backgroundColor = [UIColor colorWithRed:113/255.0 green:111/255.0 blue:224/255.0 alpha:1];
        }else{
            _C_bgView.backgroundColor = [UIColor clearColor];
            UIView *bg = [UIView new];
            bg.backgroundColor = [UIColor colorWithRed:113/255.0 green:111/255.0 blue:224/255.0 alpha:1];
            bg.tag = 10086;
//            [_bgView addSubview:bg];
        }
        _C_bgView.userInteractionEnabled = YES;
        [_C_bgView addSubview:self.C_headImg];
        [_C_bgView addSubview:self.C_tipsLab];
        [self B_initUI];
    }
    return self;
}

-(void)B_initUI{
    
//    _tipsLab.text = _tipStr;
    _C_tipsLab.attributedText = [[NSAttributedString alloc] initWithString:_C_tipStr attributes:@{
        NSForegroundColorAttributeName : [UIColor colorWithWhite:.2 alpha:1],
        NSFontAttributeName : [self B_getFontWithUnderSix:C_IS_PAD?12:16]
    }];
    
    _C_headImg.image = [_C_image isKindOfClass:[NSString class]]?[UIImage imageNamed:_C_image]:[_C_image isKindOfClass:[UIImage class]]?_C_image:[UIImage imageNamed:@"bg"];
    NSArray *C_fs = @[@(1.0),@(1.3),@(0.9),@(1.1)];
    NSArray *C_ts = @[@(1.3),@(0.9),@(1.1),@(1.0)];
    NSArray *C_ds = @[@(.2),@(.1),@(.2),@(.1)];
    
    switch (_C_type) {
        case 4:
        {
            _C_bgView.frame = CGRectMake((self.C_width-self.C_height*.388/.75)/2, (self.C_height-self.C_height*.388)/2, self.C_height*.388/.75, self.C_height*.388);
            UIButton *C_clearbtn = [self viewWithTag:1098];
            C_clearbtn.userInteractionEnabled = NO;
            
            _C_bgView.backgroundColor = [UIColor clearColor];
            
            _C_headImg.frame = CGRectMake(0, 0, _C_bgView.C_width, _C_bgView.C_height);
            
            _C_tipsLab.attributedText = [[NSAttributedString alloc] initWithString:_C_tipStr attributes:@{
                NSForegroundColorAttributeName : [UIColor colorWithWhite:.95 alpha:1],
                NSFontAttributeName : [self B_getFontWithUnderSix:C_IS_PAD?35:40]
            }];
            
            
            _C_tipsLab.frame = CGRectMake((_C_bgView.C_width-_C_bgView.C_height*.46)/2, _C_bgView.C_height*.27, _C_bgView.C_height*.46, _C_bgView.C_height*.46);
            _C_tipsLab.layer.borderColor = [UIColor blueColor].CGColor;
            _C_tipsLab.layer.borderWidth = _C_bgView.C_height*.0375;
            _C_tipsLab.layer.masksToBounds = YES;
            _C_tipsLab.layer.cornerRadius = _C_tipsLab.C_width/2;
            if(_C_animated){
                NSString *version = [UIDevice currentDevice].systemVersion;
                if (version.doubleValue >= 10.0) {
                    [self B_fs:C_fs ts:C_ts ds:C_ds];
                }
            }
        }
            break;
        case 0:
        {
            _C_bgView.frame = CGRectMake((C_WIDTHDiv-C_HEIGHTDiv*.7)/2, (C_HEIGHTDiv-C_HEIGHTDiv*.5)/2, C_HEIGHTDiv*.7, C_HEIGHTDiv*.5);
            UIImageView *imgbg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"over_bg"]];
            imgbg.frame = CGRectMake(0, 0, C_HEIGHTDiv*.7, C_HEIGHTDiv*.7*.73);
            [_C_bgView addSubview:imgbg];
//            _bgView.backgroundColor = [UIColor colorWithRed:113/255.0 green:111/255.0 blue:226/255.0 alpha:1];
//            _bgView.layer.borderColor = [UIColor redColor].CGColor;
//            _bgView.layer.borderWidth = _bgView.C_height*.015;
//            _bgView.layer.masksToBounds = YES;
//            _bgView.layer.cornerRadius = 5;
//            _bgView.layer.masksToBounds = YES;
//            _bgView.layer.cornerRadius = IS_IPAD?35:25;
            UIButton *clearbtn = [self viewWithTag:1098];
            clearbtn.userInteractionEnabled = NO;
//            UIView *bg = [_bgView viewWithTag:10086];
//            bg.frame = CGRectMake(0, _bgView.C_height*.314, _bgView.C_width, _bgView.C_height - _bgView.C_height*.314);
            
            _C_headImg.frame = CGRectMake(0, 0, _C_bgView.C_width, _C_bgView.C_height);
            
            _C_tipsLab.frame = CGRectMake(_C_bgView.C_width*.05, _C_bgView.C_height*.05, _C_bgView.C_width-_C_bgView.C_width*.05*2, _C_bgView.C_height*.2);
            
            _C_tipsLab.attributedText = [[NSAttributedString alloc] initWithString:[[_C_tipStr componentsSeparatedByString:@"&&"] firstObject] attributes:@{
                NSForegroundColorAttributeName : [UIColor whiteColor],
                NSFontAttributeName : [self B_getFontWithUnderSix:C_IS_PAD?24:28]
            }];
            float C_btnw = C_HEIGHTDiv*.15;
            float C_btnh = C_HEIGHTDiv*.15;
            float C_jianxi = (_C_bgView.C_width - C_btnw*2)/5.0;
            
            
            UILabel *C_lab = [[UILabel alloc]initWithFrame:CGRectMake(_C_bgView.C_width*.05, _C_tipsLab.C_bottom, _C_bgView.C_width*.9, _C_bgView.C_height-_C_bgView.C_height*.3-C_btnh)];
            C_lab.textAlignment = NSTextAlignmentCenter;
            C_lab.textColor = [UIColor whiteColor];
            C_lab.font = [self B_getFontWithUnderSix:C_IS_PAD?16:20];
            C_lab.text = [[_C_tipStr componentsSeparatedByString:@"&&"] lastObject];
            [_C_bgView addSubview:C_lab];
            
//            NSArray *btnImgs = @[@"player/tips/2",@"player/tips/2"];
            
            
            
            for (int i = 0; i < _C_options.count; i++) {
                UIButton *C_btn = [[UIButton alloc]initWithFrame:(_C_options.count == 2)?CGRectMake(C_jianxi*2+(_C_options.count-1-i)*(C_jianxi+C_btnw), (_C_bgView.C_height-C_btnh)*.55, C_btnw, C_btnh):CGRectMake((_C_bgView.C_width - C_btnw)/2.0, _C_bgView.C_height-C_btnh*1.45, C_btnw, C_btnh)];
                C_btn.tag = 300+i;
                [C_btn setBackgroundImage:[UIImage imageNamed:_C_options[i]] forState:UIControlStateNormal];
                [C_btn addTarget:self action:@selector(B_promptBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [_C_bgView addSubview:C_btn];
            }
            
            if(_C_animated){
                NSString *version = [UIDevice currentDevice].systemVersion;
                if (version.doubleValue >= 10.0) {
                    [self B_fs:C_fs ts:C_ts ds:C_ds];
                }
            }
        }
            break;
        
    }
}

-(void)B_showTimeBtnClick:(UIButton *)C_sender{
    
    if(C_sender.tag - 300 != 6){
        
        for (int C_i = 0; C_i < 6; C_i++){
            UIButton *C_btn = [_C_bgView viewWithTag:300+C_i];
            UIView *C_view = [C_btn viewWithTag:1000+C_i];
            if(C_sender.tag - 300 == C_i){
                C_view.backgroundColor = [UIColor whiteColor];
                C_view.layer.masksToBounds = YES;
                C_view.layer.borderColor = [UIColor colorWithRed:57/255.0 green:131/255.0 blue:224/255.0 alpha:1].CGColor;
                C_view.layer.borderWidth = C_view.C_width/4;
            }else{
                C_view.backgroundColor = [UIColor colorWithRed:148/255.0 green:197/255.0 blue:232/255.0 alpha:1];
                C_view.layer.masksToBounds = YES;
                C_view.layer.borderColor = [UIColor clearColor].CGColor;
                C_view.layer.borderWidth = 0;
            }
        }
        if(_block){
            _block((int)C_sender.tag - 300);
        }
    }else{
        [self removeFromSuperview];
    }
}

-(void)B_removeselfBtnClick{
    [self removeFromSuperview];
}

-(void)B_promptBtnClick:(UIButton *)sender{
    [self removeFromSuperview];
    if(_block){
        _block((int)sender.tag - 300);
    }
}

-(void)B_fs:(NSArray*)C_fs ts:(NSArray*)C_ts ds:(NSArray*)C_ds{
    CABasicAnimation *C_animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    C_animation.fromValue=[NSNumber numberWithFloat:[C_fs[_C_animaindex] doubleValue]];
    C_animation.toValue=[NSNumber numberWithFloat:[C_ts[_C_animaindex] doubleValue]];
    C_animation.duration=[C_ds[_C_animaindex] doubleValue];
    C_animation.autoreverses=NO;
    C_animation.repeatCount=1;
    C_animation.removedOnCompletion=NO;
    C_animation.fillMode=kCAFillModeForwards;
    [_C_bgView.layer addAnimation:C_animation forKey:@"zoom"];
    [NSTimer scheduledTimerWithTimeInterval:[C_ds[_C_animaindex] doubleValue] repeats:NO block:^(NSTimer * _Nonnull timer) {
        if(self->_C_animaindex == 3){
            if(self->_C_options.count == 0){
                double C_seconds = 0.5;
                C_seconds += self->_C_tipStr.length*0.15;
                if (C_seconds>3.0) {
                    C_seconds = 3.0;
                }
                if (C_seconds < 1) {
                    C_seconds += 0.5;
                }
                
                    [NSTimer scheduledTimerWithTimeInterval:.4 repeats:NO block:^(NSTimer * _Nonnull timer) {
                        
                        _C_tipsLab.attributedText = [[NSAttributedString alloc] initWithString:@"2" attributes:@{
                            NSForegroundColorAttributeName : [UIColor colorWithWhite:.95 alpha:1],
                            NSFontAttributeName : [self B_getFontWithUnderSix:C_IS_PAD?35:40]
                        }];
                        [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                            
                            _C_tipsLab.attributedText = [[NSAttributedString alloc] initWithString:@"1" attributes:@{
                                NSForegroundColorAttributeName : [UIColor colorWithWhite:.95 alpha:1],
                                NSFontAttributeName : [self B_getFontWithUnderSix:C_IS_PAD?35:40]
                            }];
                            [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                                if(_block){
                                    _block(1);
                                }
                                [self removeFromSuperview];
                            }];
                        }];
                    }];
                    
                
            }
            return;
        }
        _C_animaindex++;
        [self B_fs:C_fs ts:C_ts ds:C_ds];
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

-(void)dealloc{
    NSLog(@"promptView dealloc");
}

@end

@implementation A_MJpromptHelp


+(void)B_MJshow:(NSString *)str view:(UIView *)view options:(NSArray *)options finishBack:(MJfinishBlock)block animated:(BOOL)animated{
    A_MJpromptView *pView = [[A_MJpromptView alloc] B_initWithTipString:str image:nil options:options type:0 animated:animated];
    pView.block = (^(int tag){
        block(tag);
    });
    [view addSubview:pView];
}

+(void)B_MJshowTimeView:(UIView *)C_view finishBack:(MJfinishBlock)C_block {
    A_MJpromptView *C_pView = [[A_MJpromptView alloc] B_initWithTipString:@"3" image:@"naozhong" options:@[] type:4 animated:YES];
    C_pView.block = (^(int C_tag){
        C_block(C_tag);
    });
    [C_view addSubview:C_pView];
}

-(void)dealloc{
    NSLog(@"MJpromptHelp dealloc");
}

@end
