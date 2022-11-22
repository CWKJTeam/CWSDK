//
//  UIButton+ClickAdd.m
//  EmptyProject
//
//  Created by 叶建辉 on 2021/12/1.
//

#import "UIButton+A_ClickAdd.h"
#import "A_JHHelp.h"
#import <objc/runtime.h>
@implementation UIButton (A_ClickAdd)
+ (void)load{

    [super load];

//拿到sendAction方法，
//    Method oldObjectAtIndex =class_getInstanceMethod([UIButton class],@selector(sendAction:to:forEvent:));
//
////定义一个新的方法custom_sendAction
//    Method newObjectAtIndex =class_getInstanceMethod([UIButton class], @selector(custom_sendAction:to:forEvent:));
//
////交换两个方法的指针
//    method_exchangeImplementations(oldObjectAtIndex, newObjectAtIndex);

}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    NSString *key = @"appStarNumber";
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    NSString *number = [def objectForKey:key];
    NSInteger num1 = number.integerValue;
    num1 += 1;
    number = [NSString stringWithFormat:@"%zd",num1];
    [def setObject:number forKey:key];
    [def synchronize];
//    NSLog(@"number->%@",number);
    [[NSUserDefaults standardUserDefaults] setObject:[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]] forKey:@"logout_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super sendAction:action to:target forEvent:event];
}

//- (void)custom_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
//    if (1==1) {
//        NSLog(@"自定义方法");
//    }else{
//        [self custom_sendAction:action to:target forEvent:event];
////调用custom_sendAction方法，其实指针是指向的原来的sendAction方法
//    }
//}


@end
