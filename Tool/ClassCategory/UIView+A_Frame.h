//
//  UIView+Frame.h
//  ZM_NavTabBar
//
//  Created by tangdi on 15/9/23.
//  Copyright (c) 2015年 ZM. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (A_Frame)


@property (nonatomic , assign) CGFloat C_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic , assign) CGFloat C_top;         ///< Shortcut for frame.origin.y
@property (nonatomic , assign) CGFloat C_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic , assign) CGFloat C_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic , assign) CGFloat C_width;       ///< Shortcut for frame.size.width.
@property (nonatomic , assign) CGFloat C_height;      ///< Shortcut for frame.size.height.
@property (nonatomic , assign) CGFloat C_centerX;     ///< Shortcut for center.x
@property (nonatomic , assign) CGFloat C_centerY;     ///< Shortcut for center.y
@property (nonatomic , assign) CGPoint C_origin;      ///< Shortcut for frame.origin.
@property (nonatomic , assign) CGSize  C_size;        ///< Shortcut for frame.size.
+ (instancetype)B_viewFromXib;
/** 判断一个控件是否真正显示在主窗口 */
-(BOOL)B_isShowIngOnKeyWindow;








@end
