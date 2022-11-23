//
//  UIView+Frame.m
//  ZM_NavTabBar
//
//  Created by tangdi on 15/9/23.
//  Copyright (c) 2015年 ZM. All rights reserved.
//

#import "UIView+A_Frame.h"

@implementation UIView (A_Frame)


- (CGFloat)C_left
{
    return self.frame.origin.x;
}

- (void)setC_left:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)C_top
{
    return self.frame.origin.y;
}

- (void)setC_top:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)C_right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setC_right:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)C_bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setC_bottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)C_width
{
    return self.frame.size.width;
}

- (void)setC_width:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)C_height
{
    return self.frame.size.height;
}

- (void)setC_height:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)C_centerX
{
    return self.center.x;
}



- (void)setC_centerX:(CGFloat)centerX
{
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)C_centerY
{
    return self.center.y;
}

- (void)setC_centerY:(CGFloat)centerY
{
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGPoint)C_origin
{
    return self.frame.origin;
}

- (void)setC_origin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)C_size
{
    return self.frame.size;
}

- (void)setC_size:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


+ (instancetype)viewFromXib
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] lastObject];
}

-(BOOL)isShowIngOnKeyWindow
{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    
    CGRect  newFrame = [keyWindow convertRect:self.frame fromView:self.superview];
    CGRect  winBounds = keyWindow.bounds;
    
    BOOL intersects = CGRectIntersectsRect(newFrame, winBounds);
    
//    NSLog(@"-----%@----%lf- ----%@ --- %@",self.hidden?@"hidden不显示":@"hidden正常",self.alpha,self.window == keyWindow?@"当前window正常":@"window不正常",intersects?@"视图跟window相交正常":@"视图跟window相交不正常");
    
    return !self.isHidden && self.alpha > 0.0;
}

@end
