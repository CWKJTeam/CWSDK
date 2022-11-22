//
//  GameView.m
//  EmptyProj
//
//  Created by 钟志南志南 on 2022/10/13.
//

#import "A_GameView.h"
#import "A_Popupview.h"
#import "A_BViewController.h"
#import "A_TextImgView.h"
@interface A_GameView()<GameViewdelegate>

@property(nonatomic,assign)int C_time_num;
@property(nonatomic,strong)A_TextImgView *C_textimg;

@property(nonatomic,strong)UIImageView *C_img_0;
@property(nonatomic,strong)UIImageView *C_img_1;

@property(nonatomic,strong)NSMutableArray *C_coordinate_x;
@property(nonatomic,strong)NSMutableArray *C_coordinate_y;

@property(nonatomic,assign)NSInteger C_rightnum;
@property(nonatomic,strong)NSMutableArray *C_flagarray;

@property(nonatomic,strong)NSTimer *C_timer2;
@property(nonatomic,assign)Boolean C_flagpopu;

@end


@implementation A_GameView

- (A_TextImgView *)C_textimg{
    if (!_C_textimg) {
        _C_textimg = [A_TextImgView new];
        _C_textimg.C_prefixstr = @"ea_num_";
    }
    return _C_textimg;
}


-(void)setC_level:(NSInteger)C_level{
    
    _C_level = C_level;
    [self B_initUI];
    _C_img_0.image = [UIImage imageNamed:[NSString stringWithFormat:@"level_%ld_0",(long)_C_level]];
    _C_img_1.image = [UIImage imageNamed:[NSString stringWithFormat:@"level_%ld_1",(long)_C_level]];
    [self B_countdown];
}

-(void)B_popu{
    [A_Popupview B_showFailure:0 title:@"" view:self btnblock:^(int C_tag) {
        if (C_tag == 0 ) {
            [self B_regame];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *C_t = [touches anyObject];
    CGPoint C_dection = [C_t locationInView:self.superview];
    CGPoint C_dection_train = [self convertPoint:C_dection toView:_C_img_1];
    Boolean C_flag = false;
    
    for (int i = 0; i < 5;i++) {
        UIImageView *C_circle = [_C_img_1 viewWithTag:700+i];
        if (CGRectContainsPoint(C_circle.frame, C_dection_train) && [_C_flagarray[i] intValue]  == 0) {
            C_circle.image = [UIImage imageNamed:@"game_circle.png"];
            
            UIImageView *C_ifright = [self viewWithTag:500+_C_rightnum];
            C_ifright.image = C_ifright.image = [UIImage imageNamed:@"game_right"];
            C_ifright.frame = CGRectMake(C_ifright.C_left -  C_ifright.C_width*.47/2 , C_ifright.C_top - C_ifright.C_height*.47/2, C_ifright.C_width*1.47, C_ifright.C_height*1.47);
            
            _C_flagarray[i] = @1;
            _C_rightnum++;
        }
        if (CGRectContainsPoint(C_circle.frame, C_dection_train)) {
            C_flag = true;
        }
    }
    

    if (C_flag == false && _C_flagpopu == NO && CGRectContainsPoint(_C_img_1.frame, C_dection_train)){
        
        UIImageView *C_wrong = [_C_img_1 viewWithTag:800];
        C_wrong.frame = CGRectMake(C_dection_train.x - _C_img_1.C_width*.04, C_dection_train.y - _C_img_1.C_width*.04, _C_img_1.C_width*.08, _C_img_1.C_width*.08);
        C_wrong.alpha = 1;
        [UIView animateWithDuration:1 animations:^{ C_wrong.alpha = 0; } completion:^(BOOL finished){ }];
        
        UILabel *C_label = [UILabel new];
        C_label.text = @"-10";
        C_label.textColor = [UIColor redColor];
        C_label.font = [UIFont boldSystemFontOfSize:_C_img_1.C_width*.07];
        [self addSubview: C_label];
        C_label.frame = CGRectMake(C_dection.x - self->_C_img_1.C_width*.06, C_dection.y - self->_C_img_1.C_width*.07, self->_C_img_1.C_width*.15, self->_C_img_1.C_width*.15);
        
        [UIView animateWithDuration:2 animations:^{
            C_label.frame = CGRectMake(WIDTHDiv*.72, WIDTHDiv*.21, self->_C_img_1.C_width*.15, self->_C_img_1.C_width*.15);

        } completion:^(BOOL finished){
            [C_label removeFromSuperview];
            if (self.C_time_num > 9) {
                self.C_time_num -= 10;
            }else{
                self.C_time_num = 0;
            }
            self->_C_textimg.C_textstr =  [NSString stringWithFormat:@"%d",self->_C_time_num];
        }];
        
        
    }
    
    if (_C_rightnum == 5 && _C_level != 4) {
        [self B_nextlevel];
    }
    else if (_C_level == 4 && _C_rightnum == 5 ) {
        [self B_rehome];
    }
}

-(void)B_initUI{
    _C_time_num = 90;
    _C_rightnum = 0;
    _C_flagarray = @[@0,@0,@0,@0,@0].mutableCopy;
    _C_flagpopu = NO;
    
    UIButton *C_rebtn = [UIButton new];
    C_rebtn.tag = 200;
    [C_rebtn setImage:[UIImage imageNamed:@"game_rebtn"] forState:0];
    [C_rebtn addTarget:self action:@selector(B_rehome) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:C_rebtn];
    
    UIImageView  *C_levelshow = [UIImageView new];
    C_levelshow.tag = 300;
    C_levelshow.image = [UIImage imageNamed:[NSString stringWithFormat:@"level_num_%ld",(long)_C_level]];
    [self addSubview:C_levelshow];
    
    UIImageView *C_timebg = [UIImageView new];
    C_timebg.tag = 400;
    C_timebg.image = [UIImage imageNamed:@"game_time"];
    [self addSubview:C_timebg];
    
    [C_timebg addSubview:self.C_textimg];
    _C_textimg.C_textstr =  [NSString stringWithFormat:@"%d",_C_time_num];
    
    
    for (int i = 0; i < 5; i++) {
        UIImageView *C_ifright = [UIImageView new];
        C_ifright.tag = 500 + i;
        C_ifright.image = [UIImage imageNamed:@"game_wenhao"];
        [self addSubview:C_ifright];
    }
    for (int i = 0; i < 5; i++) {
        UIImageView *C_ifright = [self viewWithTag:500+i];
        C_ifright.frame = CGRectMake((WIDTHDiv - HEIGHTDiv*.35)/2 + HEIGHTDiv*.077*i, HEIGHTDiv*.2, HEIGHTDiv*.05, HEIGHTDiv*.05);
    }
    
    for (int i = 0; i < 2; i++) {
        UIImageView *C_frame = [UIImageView new];
        C_frame.tag = 600 + i;
        C_frame.image = [UIImage imageNamed:@"game_frame"];
        [self addSubview:C_frame];
        
        if(i == 0 ){
            UIImageView *C_imgbg0 = [UIImageView new];
            C_imgbg0.tag = 610+i;
            [C_frame addSubview:C_imgbg0];
            
            self.C_img_0 = [UIImageView new];
            [C_imgbg0 addSubview:self.C_img_0];
        }else{
            UIImageView *C_imgbg1 = [UIImageView new];
            C_imgbg1.tag = 610+i;
            [C_frame addSubview:C_imgbg1];
            
            self.C_img_1 = [UIImageView new];
            self.C_img_1.layer.masksToBounds = YES;
            [C_imgbg1 addSubview:self.C_img_1];
        }
    }

    for (int i = 0; i < 5; i++) {
        UIImageView *C_circle = [UIImageView new];
        C_circle.tag = 700 + i;
        [_C_img_1 addSubview:C_circle];
    }
    
    UIImageView *C_wrong = [UIImageView new];
    C_wrong.tag = 800;
    C_wrong.image = [UIImage imageNamed:@"game_wrong"];
    [_C_img_1 addSubview:C_wrong];
   
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if(self){
        
        _C_coordinate_x = @[
                                @[@"0.63",@"0.36",@"0.47",@"0.8",@"0.54"],
                                @[@"0.21",@"0.05",@"0.41",@"0.82",@"0.8"],
                                @[@"0.13",@"0.54",@"0.9",@"0.82",@"0.46"],
                                @[@"0.05",@"0.46",@"0.67",@"0.69",@"0.39"],
                                @[@"0.04",@"0.2",@"0.895",@"0.49",@"0.72"],
                            ].mutableCopy;
        
        _C_coordinate_y = @[
                                @[@"0.37",@"0.49",@"0.6",@"0.55",@"0.03"],
                                @[@"0.21",@"0.72",@"0.56",@"0.78",@"0.49"],
                                @[@"0.57",@"0.42",@"0.63",@"0.74",@"0.29"],
                                @[@"0.56",@"0.1",@"0.2",@"0.62",@"0.64"],
                                @[@"0.18",@"0.27",@"0.15",@".62",@"0.59"],
                            ].mutableCopy;
        
    }
    return self;
}

-(void)B_countdown{
    _C_timer2 = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(B_refresh_time) userInfo:nil repeats:YES];
}
-(void)B_refresh_time{
    if (self.C_time_num > 0) {
        self.C_time_num--;
    }
    _C_textimg.C_textstr =  [NSString stringWithFormat:@"%d",_C_time_num];
    if (self.C_time_num == 0) {
        [_C_timer2 invalidate];
        _C_flagpopu = YES;
        if (@available(iOS 10.0, *)) {
            [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
                [self B_popu];
            }];
        } else {
        }
    }
}

-(void)B_rehome{
    if ([self.deledete respondsToSelector:@selector(B_rehome)]) {
        [self.deledete B_rehome];
    }
}

-(void)B_regame{
    if ([self.deledete respondsToSelector:@selector(B_regame)]) {
        [self.deledete B_regame];
    }
}

-(void)B_nextlevel{
    if ([self.deledete respondsToSelector:@selector(B_nextlevel)]) {
        [self.deledete B_nextlevel];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    UIButton *C_rebtn = [self viewWithTag:200];
    C_rebtn.frame = CGRectMake(WIDTHDiv*.05, HEIGHTDiv*.05, HEIGHTDiv*.08*1.67, HEIGHTDiv*.08);
    
    UIImageView *C_levelshow = [self viewWithTag:300];
    C_levelshow.frame = CGRectMake(WIDTHDiv*.07, HEIGHTDiv*.15, HEIGHTDiv*.03*4.4 , HEIGHTDiv*.03);
    
    UIImageView *C_timebg = [self viewWithTag:400];
    C_timebg.frame = CGRectMake(WIDTHDiv*.65, WIDTHDiv*.05, HEIGHTDiv*.17, HEIGHTDiv*.17);
    
    _C_textimg.frame = CGRectMake(C_timebg.C_width*.22, C_timebg.C_height*.2, C_timebg.C_width*.6, C_timebg.C_height*.55);
    
    for (int i = 0 ; i < 2; i++) {
        UIImageView *C_frame = [self viewWithTag:600+i];
        C_frame.frame = CGRectMake((WIDTHDiv - HEIGHTDiv*.37*1.16)/2, HEIGHTDiv*.26 +  HEIGHTDiv*.355*i,HEIGHTDiv*.37*1.16, HEIGHTDiv*.37);
        
        if (i == 0) {
            UIImageView *C_imgbg0 = [C_frame viewWithTag:610+i];
            C_imgbg0.frame = CGRectMake(C_frame.C_width*.07, C_frame.C_height*.1, C_frame.C_width*.87, C_frame.C_height*.81);
            self.C_img_0.frame = CGRectMake(0, 0, C_imgbg0.C_width, C_imgbg0.C_height);
        }else{
            UIImageView *C_imgbg1 = [C_frame viewWithTag:610+i];
            C_imgbg1.frame = CGRectMake(C_frame.C_width*.07, C_frame.C_height*.1, C_frame.C_width*.87, C_frame.C_height*.81);
            self.C_img_1.frame = CGRectMake(0, 0, C_imgbg1.C_width, C_imgbg1.C_height);
        }
    }
    
    for (int i = 0; i < 5; i++) {
        UIImageView *C_circle = [_C_img_1 viewWithTag:700+i];
        C_circle.frame = CGRectMake([_C_coordinate_x[_C_level][i] doubleValue] * _C_img_1.C_width,[_C_coordinate_y[_C_level][i] doubleValue] * _C_img_1.C_height, _C_img_1.C_width*.1, _C_img_1.C_width*.1);
    }

}
 @end
    
