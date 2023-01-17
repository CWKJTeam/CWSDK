//
//  JHLabel.m
//  500006
//
//  Created by 叶建辉 on 2021/11/26.
//  Copyright © 2021 DCloud. All rights reserved.
//

#import "A_JHLabel.h"

@implementation A_JHLabel

- (void)drawTextInRect:(CGRect)rect {
 
   CGSize shadowOffset = self.shadowOffset;
   UIColor *textColor = self.textColor;
 
   CGContextRef c = UIGraphicsGetCurrentContext();
   CGContextSetLineWidth(c, _C_lineWidth);
   CGContextSetLineJoin(c, kCGLineJoinRound);
 
   CGContextSetTextDrawingMode(c, kCGTextStroke);
   self.textColor = _C_labelColor;
//    [UIColor colorWithRed:249.0/255.0 green:192.0/255.0 blue:61.0/255.0 alpha:1]
   [super drawTextInRect:rect];
 
   CGContextSetTextDrawingMode(c, kCGTextFill);
   self.textColor = textColor;
   self.shadowOffset = CGSizeMake(0, 0);
   [super drawTextInRect:rect];
 
   self.shadowOffset = shadowOffset;
 
}

@end
