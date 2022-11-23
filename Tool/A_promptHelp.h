//
//  promptHelp.h
//  Unity-iPhone
//
//  Created by QPX on 2019/5/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^finishBlock)(int tag);

@interface A_promptHelp : NSObject

+(void)B_show:(NSString *)str view:(UIView *)view options:(NSArray *)options finishBack:(finishBlock)block animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
