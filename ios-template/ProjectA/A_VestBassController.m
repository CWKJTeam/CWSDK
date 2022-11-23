//
//  VestBassController.m
//  EmptyProject
//
//  Created by 叶建辉 on 2021/12/1.
//

#import "A_VestBassController.h"
#import "A_Tool.h"
@interface A_VestBassController ()

@end

@implementation A_VestBassController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *C_selfClass = NSStringFromClass([self class]);
    NSUserDefaults *C_ud = [NSUserDefaults standardUserDefaults];
    [C_ud setObject:C_selfClass forKey:@"last_scene"];
    [C_ud synchronize];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSString *C_key = @"appStarNumber";
    NSUserDefaults *C_def = [NSUserDefaults standardUserDefaults];
    NSString *C_number = [C_def objectForKey:C_key];
    NSInteger C_num1 = C_number.integerValue;
    C_num1 += 1;
    C_number = [NSString stringWithFormat:@"%zd",C_num1];
    [C_def setObject:C_number forKey:C_key];
    [C_def synchronize];
//    NSLog(@"number->%@",number);
    [[NSUserDefaults standardUserDefaults] setObject:[A_JHHelp B_transTotimeSp:[A_JHHelp B_getNowTimeTimestamp]] forKey:@"logout_time"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures{
    return UIRectEdgeAll;
}

@end
