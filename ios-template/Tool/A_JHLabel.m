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
   CGContextSetLineWidth(c, 2);
   CGContextSetLineJoin(c, kCGLineJoinRound);
 
   CGContextSetTextDrawingMode(c, kCGTextStroke);
   self.textColor = [UIColor blueColor];
   [super drawTextInRect:rect];
 
   CGContextSetTextDrawingMode(c, kCGTextFill);
   self.textColor = textColor;
   self.shadowOffset = CGSizeMake(0, 0);
   [super drawTextInRect:rect];
 
   self.shadowOffset = shadowOffset;
 
}
@end
