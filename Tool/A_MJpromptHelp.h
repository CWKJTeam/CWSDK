//
//  promptHelp.h
//  Unity-iPhone
//
//  Created by QPX on 2019/5/15.
//

#import <Foundation/Foundation.h>
#import "A_Tool.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^MJfinishBlock)(int tag);

@interface A_MJpromptHelp : NSObject

+(void)B_MJshow:(NSString *)C_str view:(UIView *)C_view options:(NSArray *)C_options finishBack:(MJfinishBlock)C_block animated:(BOOL)C_animated;

+(void)B_MJshowTimeView:(UIView *)C_view finishBack:(MJfinishBlock)C_block;
@end

NS_ASSUME_NONNULL_END
