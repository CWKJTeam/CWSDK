//
//  promptHelp.m
//  Unity-iPhone
//
//  Created by QPX on 2019/5/15.
//
#import "UIView+A_Frame.h"
#import "UIImage+A_setImageStrName.h"
#import "A_promptHelp.h"
#import "A_JHHelp.h"
#import "A_Tool.h"
@interface promptView : UIView


- (instancetype)initWithTipString:(NSString *)TipString image:(id)obj options:(NSArray *)options type:(int)type animated:(BOOL)animated;

@property(nonatomic,assign)int C_type;

@property (nonatomic, copy) void(^block)(int tag);

@property(nonatomic,strong)NSString *C_tipStr;

@property(nonatomic,strong)id C_image;

@property(nonatomic,strong)NSArray *C_options;

@end

@interface promptView ()

@property(nonatomic,strong)UILabel *C_tipsLab;

@property(nonatomic,strong)UIView *C_bgView;

@property(nonatomic,strong)UIImageView *C_headImg;

@property(nonatomic,assign)int C_animaindex;

@property(nonatomic,assign)BOOL C_animated;

@end

@implementation promptView

-(UILabel *)C_tipsLab{
    if(!_C_tipsLab){
        _C_tipsLab = [UILabel new];
        _C_tipsLab.font = [A_JHHelp B_getFontWithUnderSix:IS_IPAD?12:16];
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
//        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//        if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
//            self.frame = CGRectMake(0, 0, WIDTHDiv, HEIGHTDiv);
//        }else {
//
//        }
        
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
        [clearbtn addTarget:self action:@selector(removeselfBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearbtn];
        [self addSubview:self.C_bgView];

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
        NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:1],
        NSFontAttributeName : [A_JHHelp B_getFontWithUnderSix:IS_PAD?14:18]
    }];
    
    _C_headImg.image = [_C_image isKindOfClass:[NSString class]]?[UIImage B_imageNameds:_C_image]:[_C_image isKindOfClass:[UIImage class]]?_C_image:[UIImage B_imageNameds:@"ph-bg"];
    NSArray *fs = @[@(1.0),@(1.3),@(0.9),@(1.1)];
    NSArray *ts = @[@(1.3),@(0.9),@(1.1),@(1.0)];
    NSArray *ds = @[@(.2),@(.1),@(.2),@(.1)];
    
    switch (_C_type) {
        
        case 0:
        {
            NSLog(@"~~~~>>%@",_C_options);
            _C_bgView.frame = CGRectMake((self.C_width-(IS_IPAD?self.C_height*.55/.6:self.C_height*.76/.6))/2, (self.C_height-(IS_IPAD?self.C_height*.55:self.C_height*.76))/2, (IS_IPAD?self.C_height*.55/.6:self.C_height*.76/.6), (IS_IPAD?self.C_height*.55:self.C_height*.76));
//            _bgView.backgroundColor = [UIColor greenColor];
            _C_headImg.frame = CGRectMake(0, 0, _C_bgView.C_width, _C_bgView.C_height);
            
            _C_tipsLab.frame = CGRectMake(_C_bgView.C_width*.06+(IS_IPAD?30:20), _C_bgView.C_height*.1+(IS_IPAD?30:20), _C_bgView.C_width-(_C_bgView.C_width*.06+(IS_IPAD?30:20))*2, _C_bgView.C_height*.8-(IS_IPAD?30:20)-((_C_options.count != 0)?_C_bgView.C_height*.165:0));
            
            float btnw = _C_bgView.C_height*.165/.225;
            float btnh = _C_bgView.C_height*.165;
            float jianxi = (_C_bgView.C_width - btnw*2)/5.0;
            
            for (int i = 0; i < _C_options.count; i++) {
                UIButton *btn = [[UIButton alloc]initWithFrame:(_C_options.count == 2)?CGRectMake(jianxi*2+(_C_options.count-1-i)*(jianxi+btnw), _C_tipsLab.C_bottom, btnw, btnh):CGRectMake((_C_bgView.C_width - btnw)/2.0, _C_tipsLab.C_bottom, btnw, btnh)];
//                [btn setBackgroundColor:[UIColor yellowColor]];
                btn.titleLabel.font = [A_JHHelp B_getboldFontWithUnderSix:IS_IPAD?13:17];
                btn.tag = 300+i;
                [btn setBackgroundImage:[UIImage B_imageNameds:_C_options[i]] forState:UIControlStateNormal];
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
        
//        [self promptBtnClick:sender];
        if(_block){
            _block((int)sender.tag - 300);
        }
    }else{
        [self removeFromSuperview];
    }
}

-(void)removeselfBtnClick{
//    [self removeFromSuperview];
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
    __weak promptView *mySelf = self;
    [NSTimer scheduledTimerWithTimeInterval:[ds[mySelf.C_animaindex] doubleValue] repeats:NO block:^(NSTimer * _Nonnull timer) {
        NSLog(@"_animaindex->%d    _type->%d",mySelf.C_animaindex,mySelf.C_type);
        if(mySelf.C_animaindex == 3){
            if(mySelf.C_type == 1){
                [NSTimer scheduledTimerWithTimeInterval:1.2 repeats:NO block:^(NSTimer * _Nonnull timer) {
                    if(mySelf.block){
                        mySelf.block(mySelf.C_type);
                    }
                    [self removeFromSuperview];
                }];
            }else{
                if(mySelf.C_options.count == 0){
                    double seconds = 0.5;
                    seconds += mySelf.C_tipStr.length*0.15;
                    if (seconds>3.0) {
                        seconds = 3.0;
                    }
                    if (seconds < 1) {
                        seconds += 0.5;
                    }
                    [NSTimer scheduledTimerWithTimeInterval:seconds repeats:NO block:^(NSTimer * _Nonnull timer) {
                        
                        [self removeFromSuperview];
                    }];
                }
            }
            return;
        }
        mySelf.C_animaindex++;
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

@implementation A_promptHelp

+(void)B_show:(NSString *)str view:(UIView *)view options:(NSArray *)options finishBack:(finishBlock)block animated:(BOOL)animated{
    promptView *pView = [[promptView alloc]initWithTipString:str image:nil options:options type:0 animated:animated];
    pView.block = (^(int tag){
        block(tag);
    });
    [view addSubview:pView];
}

-(void)dealloc{
    NSLog(@"promptHelp dealloc");
}

@end
