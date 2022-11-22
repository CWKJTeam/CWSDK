//
//  TextImgView.m
//  EmptyProj
//
//  Created by 叶建辉 on 2022/7/12.
//

#import "A_TextImgView.h"

@implementation A_TextImgView

-(void)layoutSubviews{
    [super layoutSubviews];
    
//    if ([_textstr isEqualToString:@"0"]) {
//        UIImageView *imgstr =[self viewWithTag:100];
//        imgstr.frame = CGRectMake(0, 0, self.C_width, self.C_height);
//    }else{
    if ([_C_textstr isEqualToString:@"mh"]) {
        UIImageView *imgstr =[self viewWithTag:100];
        imgstr.image = [UIImage imageNamed:@"ea_mh"];
        imgstr.frame = CGRectMake(0, 0, self.C_width, self.C_height);
    }else{
        float a = 0;
        for (int i = 0 ; i < _C_textstr.length; i++) {
            NSString *temp = [_C_textstr substringWithRange:NSMakeRange(i, 1)];
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",_C_prefixstr,temp]];
            a += image.size.width/image.size.height*self.C_height*.4;
        }
        float w = 0;
        for (int i = 0 ; i < _C_textstr.length; i++) {
            UIImageView *imgstr = [self viewWithTag:100+i];
            NSString *temp = [_C_textstr substringWithRange:NSMakeRange(i, 1)];
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%@",_C_prefixstr,temp]];
            imgstr.frame = CGRectMake((self.C_width-a)/2+w, self.C_height*.3, image.size.width/image.size.height*self.C_height*.4, self.C_height*.4);
            w+=image.size.width/image.size.height*self.C_height*.4;
        }
    }
}

-(void)setC_textstr:(NSString *)C_textstr{
    _C_textstr = C_textstr;
    
    
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
//    if ([_textstr isEqualToString:@"0"]) {
//        UIImageView *imgstr = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_block_finish"]];
//        imgstr.tag = 100;
//        [self addSubview:imgstr];
//    }else{
//    if ([_textstr isEqualToString:@"mh"]) {
//        UIImageView *imgstr =[self viewWithTag:100];
//        imgstr.image = [UIImage imageNamed:@"ea_mh"];
//        imgstr.frame = CGRectMake(0, 0, self.C_width, self.C_height);
//    }else{
        for (int i = 0 ; i < _C_textstr.length; i++) {
            NSString *temp = [_C_textstr substringWithRange:NSMakeRange(i, 1)];
            
            UIImageView *imgstr = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@%@",_C_prefixstr,temp]]];
            imgstr.tag = 100+i;
            [self addSubview:imgstr];
            
        }
        [self setNeedsLayout];
    }
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
