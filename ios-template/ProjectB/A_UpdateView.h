//
//  UpdateView.h
//  vpower(i_1)
//
//  Created by 叶建辉 on 2021/12/8.
//  Copyright © 2021 egret. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface A_UpdateView : UIView
@property(nonatomic,assign)float C_proress;
@property(nonatomic,weak)UILabel *C_verLab;
@property(nonatomic,weak)UILabel *C_tipsLab;
@property(nonatomic,copy)NSString *C_currentLanguage;
@property(nonatomic,strong)NSDictionary *C_curLanguageDic;

@end

NS_ASSUME_NONNULL_END
