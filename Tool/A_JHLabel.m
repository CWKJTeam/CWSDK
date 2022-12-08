//
//  JHLabel.m
//  500006
//
//  Created by 叶建辉 on 2021/11/26.
//  Copyright © 2021 DCloud. All rights reserved.
//

#import "A_JHLabel.h"

@implementation A_JHLabel

- (void)drawTextInRect:(CGRect)C_rect {
 
   CGSize C_shadowOffset = self.shadowOffset;
   UIColor *C_textColor = self.textColor;
 
   CGContextRef C_c = UIGraphicsGetCurrentContext();
   CGContextSetLineWidth(C_c, 2);
   CGContextSetLineJoin(C_c, kCGLineJoinRound);
 
   CGContextSetTextDrawingMode(C_c, kCGTextStroke);
   self.textColor = [UIColor blueColor];
   [super drawTextInRect:C_rect];
 
   CGContextSetTextDrawingMode(C_c, kCGTextFill);
   self.textColor = C_textColor;
   self.shadowOffset = CGSizeMake(0, 0);
   [super drawTextInRect:C_rect];
 
   self.shadowOffset = C_shadowOffset;
 
}

@end
