//
//  promptHelp.h
//  Unity-iPhone
//
//  Created by QPX on 2019/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^MJfinishBlock)(int tag);

@interface A_MJpromptHelp : NSObject

+(void)B_MJshow:(NSString *)str view:(UIView *)view options:(NSArray *)options finishBack:(MJfinishBlock)block animated:(BOOL)animated;

+(void)B_MJshowTimeView:(UIView *)view finishBack:(MJfinishBlock)block;
@end

NS_ASSUME_NONNULL_END
