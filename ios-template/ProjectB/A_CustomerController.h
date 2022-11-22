//
//  CustomerController.h
//  (i_1)VPower
//
//  Created by 叶建辉 on 2022/4/9.
//  Copyright © 2022 egret. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface A_CustomerController : UIViewController
@property(nonatomic,strong)NSString *C_wk_id;
@property(nonatomic,strong)NSString *C_webUrl;
@property(nonatomic,strong)NSString *C_style;
@property(nonatomic,assign)UIDeviceOrientation C_duration;
@property(nonatomic,assign)BOOL C_isShuping;
- (void)B_loadLocalRequest;
@end

NS_ASSUME_NONNULL_END
