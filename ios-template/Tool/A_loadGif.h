//
//  loadGif.h
//  Unity-iPhone
//
//  Created by QPX on 2021/8/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^giflock)(UIView *view);
@interface A_loadGif : NSObject

+(void)B_show:(UIView *)view imgStr:(NSString *)imgStr repeat:(BOOL)repeat speed:(int)speed imgCount:(int)imgCount rect:(CGRect)rect;

+(void)B_show:(UIView *)view imgStr:(NSString *)imgStr repeat:(BOOL)repeat speed:(int)speed imgCount:(int)imgCount rect:(CGRect)rect bolck:(giflock)block;

+(void)B_cloose:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
