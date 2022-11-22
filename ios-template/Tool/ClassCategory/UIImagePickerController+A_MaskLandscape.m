//
//  UIImagePickerController+MaskLandscape.m
//  XGame(i_1)
//
//  Created by 叶建辉 on 2022/2/23.
//  Copyright © 2022 egret. All rights reserved.
//

#import "UIImagePickerController+A_MaskLandscape.h"

@implementation UIImagePickerController (A_MaskLandscape)

-(void)viewDidLoad{
    [super viewDidLoad];
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

@end
