//
//  Popupview.h
//  EmptyProj
//
//  Created by Liujinyang on 2022/8/11.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^winblock)(int C_tag);

@interface A_Popupview : UIView

+(void)B_showFailure:(int)winType title:(NSString*)title  view:(UIView*)view btnblock:(winblock)block;

@end

NS_ASSUME_NONNULL_END

