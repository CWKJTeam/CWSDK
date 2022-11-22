//
//  promptHelp.m
//  Unity-iPhone
//
//  Created by QPX on 2019/5/15.
//

#import "A_MJpromptHelp.h"
#import "A_JHLabel.h"
@interface MJpromptView : UIView



- (instancetype)initWithTipString:(NSString *)TipString image:(id)obj options:(NSArray *)options type:(int)type animated:(BOOL)animated;

@property(nonatomic,assign)int C_type;

@property (nonatomic, copy) void(^block)(int tag);

@property(nonatomic,strong)NSString *C_tipStr;

@property(nonatomic,strong)id C_image;

@property(nonatomic,strong)NSArray *C_options;

@end

@interface MJpromptView ()

@property(nonatomic,strong)A_JHLabel *C_tipsLab;

@property(nonatomic,strong)UIView *C_bgView;

@property(nonatomic,strong)UIImageView *C_headImg;

@property(nonatomic,assign)int C_animaindex;

@property(nonatomic,assign)BOOL C_animated;

@end

@implementation MJpromptView

-(UIFont *)B_getFontWithUnderSix:(float)underSix{
    
    CGFloat C_proportion = SIX_DIV;
    
    if (IS_IPAD) {
        C_proportion = (WIDTHDiv-IPAD_BETWEENS)/375;
    }
    
    return [UIFont systemFontOfSize:underSix*C_proportion];
}

-(UIFont *)B_getboldFontWithUnderSix:(float)underSix{
    
    CGFloat C_proportion = SIX_DIV;
    
    if (IS_IPAD) {
        C_proportion = (WIDTHDiv-IPAD_BETWEENS)/375;
    }
    
    return [UIFont boldSystemFontOfSize:underSix*C_proportion];
}


-(UILabel *)C_tipsLab{
    if(!_C_tipsLab){
        _C_tipsLab = [A_JHLabel new];
        _C_tipsLab.font = [self B_getFontWithUnderSix:IS_IPAD?12:16];
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

- (instancetype)initWithTipString:(NSString *)TipString image:(id)obj options:(NSArray *)options type:(int)type animated:(BOOL)animated
{
    if (self = [self init]) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
        float c;
        float d;
        if(WIDTHDiv>HEIGHTDiv){
            c = WIDTHDiv;
            d = HEIGHTDiv;
        }else{
            c = HEIGHTDiv;
            d = WIDTHDiv;
        }
        
        self.frame = CGRectMake(0, 0, WIDTHDiv, HEIGHTDiv);
        _C_animaindex = 0;
        _C_type = type;
        _C_tipStr = TipString;
        _C_image = obj;
        _C_options = options;
        _C_animated = animated;
        UIButton *clearbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WIDTHDiv, HEIGHTDiv)];
        clearbtn.tag = 1098;
        [clearbtn addTarget:self action:@selector(removeselfBtnClick) forControlEvents:UIControlEventTouchUpInside];
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
        [self initUI];
    }
    return self;
}

-(void)initUI{
    
//    _tipsLab.text = _tipStr;
    _C_tipsLab.attributedText = [[NSAttributedString alloc] initWithString:_C_tipStr attributes:@{
        NSForegroundColorAttributeName : [UIColor colorWithWhite:.2 alpha:1],
        NSFontAttributeName : [self B_getFontWithUnderSix:IS_PAD?12:16]
    }];
    
    _C_headImg.image = [_C_image isKindOfClass:[NSString class]]?[UIImage imageNamed:_C_image]:[_C_image isKindOfClass:[UIImage class]]?_C_image:[UIImage imageNamed:@"bg"];
    NSArray *fs = @[@(1.0),@(1.3),@(0.9),@(1.1)];
    NSArray *ts = @[@(1.3),@(0.9),@(1.1),@(1.0)];
    NSArray *ds = @[@(.2),@(.1),@(.2),@(.1)];
    
    switch (_C_type) {
        case 4:
        {
            _C_bgView.frame = CGRectMake((self.C_width-self.C_height*.388/.75)/2, (self.C_height-self.C_height*.388)/2, self.C_height*.388/.75, self.C_height*.388);
            UIButton *clearbtn = [self viewWithTag:1098];
            clearbtn.userInteractionEnabled = NO;
            
            _C_bgView.backgroundColor = [UIColor clearColor];
            
            _C_headImg.frame = CGRectMake(0, 0, _C_bgView.C_width, _C_bgView.C_height);
            
            _C_tipsLab.attributedText = [[NSAttributedString alloc] initWithString:_C_tipStr attributes:@{
                NSForegroundColorAttributeName : [UIColor colorWithWhite:.95 alpha:1],
                NSFontAttributeName : [self B_getFontWithUnderSix:IS_PAD?35:40]
            }];
            
            
            _C_tipsLab.frame = CGRectMake((_C_bgView.C_width-_C_bgView.C_height*.46)/2, _C_bgView.C_height*.27, _C_bgView.C_height*.46, _C_bgView.C_height*.46);
            _C_tipsLab.layer.borderColor = [UIColor blueColor].CGColor;
            _C_tipsLab.layer.borderWidth = _C_bgView.C_height*.0375;
            _C_tipsLab.layer.masksToBounds = YES;
            _C_tipsLab.layer.cornerRadius = _C_tipsLab.C_width/2;
            if(_C_animated){
                NSString *version = [UIDevice currentDevice].systemVersion;
                if (version.doubleValue >= 10.0) {
                    [self fs:fs ts:ts ds:ds];
                }
            }
        }
            break;
        case 0:
        {
            _C_bgView.frame = CGRectMake((WIDTHDiv-HEIGHTDiv*.7)/2, (HEIGHTDiv-HEIGHTDiv*.5)/2, HEIGHTDiv*.7, HEIGHTDiv*.5);
            UIImageView *imgbg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"over_bg"]];
            imgbg.frame = CGRectMake(0, 0, HEIGHTDiv*.7, HEIGHTDiv*.7*.73);
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
                NSFontAttributeName : [self B_getFontWithUnderSix:IS_PAD?24:28]
            }];
            float btnw = HEIGHTDiv*.15;
            float btnh = HEIGHTDiv*.15;
            float jianxi = (_C_bgView.C_width - btnw*2)/5.0;
            
            
            UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(_C_bgView.C_width*.05, _C_tipsLab.C_bottom, _C_bgView.C_width*.9, _C_bgView.C_height-_C_bgView.C_height*.3-btnh)];
            lab.textAlignment = NSTextAlignmentCenter;
            lab.textColor = [UIColor whiteColor];
            lab.font = [self B_getFontWithUnderSix:IS_PAD?16:20];
            lab.text = [[_C_tipStr componentsSeparatedByString:@"&&"] lastObject];
            [_C_bgView addSubview:lab];
            
//            NSArray *btnImgs = @[@"player/tips/2",@"player/tips/2"];
            
            
            
            for (int i = 0; i < _C_options.count; i++) {
                UIButton *btn = [[UIButton alloc]initWithFrame:(_C_options.count == 2)?CGRectMake(jianxi*2+(_C_options.count-1-i)*(jianxi+btnw), (_C_bgView.C_height-btnh)*.55, btnw, btnh):CGRectMake((_C_bgView.C_width - btnw)/2.0, _C_bgView.C_height-btnh*1.45, btnw, btnh)];
                btn.tag = 300+i;
                [btn setBackgroundImage:[UIImage imageNamed:_C_options[i]] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(promptBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                [_C_bgView addSubview:btn];
            }
            
            if(_C_animated){
                NSString *version = [UIDevice currentDevice].systemVersion;
                if (version.doubleValue >= 10.0) {
                    [self fs:fs ts:ts ds:ds];
                }
            }
        }
            break;
        
    }
}

-(void)showTimeBtnClick:(UIButton *)sender{
    
    if(sender.tag - 300 != 6){
        
        for (int i = 0; i < 6; i++){
            UIButton *btn = [_C_bgView viewWithTag:300+i];
            UIView *view = [btn viewWithTag:1000+i];
            if(sender.tag - 300 == i){
                view.backgroundColor = [UIColor whiteColor];
                view.layer.masksToBounds = YES;
                view.layer.borderColor = [UIColor colorWithRed:57/255.0 green:131/255.0 blue:224/255.0 alpha:1].CGColor;
                view.layer.borderWidth = view.C_width/4;
            }else{
                view.backgroundColor = [UIColor colorWithRed:148/255.0 green:197/255.0 blue:232/255.0 alpha:1];
                view.layer.masksToBounds = YES;
                view.layer.borderColor = [UIColor clearColor].CGColor;
                view.layer.borderWidth = 0;
            }
        }
        if(_block){
            _block((int)sender.tag - 300);
        }
    }else{
        [self removeFromSuperview];
    }
}

-(void)removeselfBtnClick{
    [self removeFromSuperview];
}

-(void)promptBtnClick:(UIButton *)sender{
    [self removeFromSuperview];
    if(_block){
        _block((int)sender.tag - 300);
    }
}

-(void)fs:(NSArray*)fs ts:(NSArray*)ts ds:(NSArray*)ds{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue=[NSNumber numberWithFloat:[fs[_C_animaindex] doubleValue]];
    animation.toValue=[NSNumber numberWithFloat:[ts[_C_animaindex] doubleValue]];
    animation.duration=[ds[_C_animaindex] doubleValue];
    animation.autoreverses=NO;
    animation.repeatCount=1;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    [_C_bgView.layer addAnimation:animation forKey:@"zoom"];
    [NSTimer scheduledTimerWithTimeInterval:[ds[_C_animaindex] doubleValue] repeats:NO block:^(NSTimer * _Nonnull timer) {
        if(_C_animaindex == 3){
            if(_C_options.count == 0){
                double seconds = 0.5;
                seconds += _C_tipStr.length*0.15;
                if (seconds>3.0) {
                    seconds = 3.0;
                }
                if (seconds < 1) {
                    seconds += 0.5;
                }
                
                    [NSTimer scheduledTimerWithTimeInterval:.4 repeats:NO block:^(NSTimer * _Nonnull timer) {
                        
                        _C_tipsLab.attributedText = [[NSAttributedString alloc] initWithString:@"2" attributes:@{
                            NSForegroundColorAttributeName : [UIColor colorWithWhite:.95 alpha:1],
                            NSFontAttributeName : [self B_getFontWithUnderSix:IS_PAD?35:40]
                        }];
                        [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
                            
                            _C_tipsLab.attributedText = [[NSAttributedString alloc] initWithString:@"1" attributes:@{
                                NSForegroundColorAttributeName : [UIColor colorWithWhite:.95 alpha:1],
                                NSFontAttributeName : [self B_getFontWithUnderSix:IS_PAD?35:40]
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
        [self fs:fs ts:ts ds:ds];
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
    MJpromptView *pView = [[MJpromptView alloc]initWithTipString:str image:nil options:options type:0 animated:animated];
    pView.block = (^(int tag){
        block(tag);
    });
    [view addSubview:pView];
}

+(void)B_MJshowTimeView:(UIView *)view finishBack:(MJfinishBlock)block {
    MJpromptView *pView = [[MJpromptView alloc]initWithTipString:@"3" image:@"naozhong" options:@[] type:4 animated:YES];
    pView.block = (^(int tag){
        block(tag);
    });
    [view addSubview:pView];
}

-(void)dealloc{
    NSLog(@"MJpromptHelp dealloc");
}

@end
