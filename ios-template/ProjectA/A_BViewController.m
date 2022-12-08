//
//  BViewController.m
//  500001
//
//  Created by 叶建辉 on 2021/11/19.
//  Copyright © 2021 DCloud. All rights reserved.
//

#import "A_BViewController.h"
#import "A_GameViewController.h"
#import "A_Reachability.h"
#import "A_UpdateController.h"
#import <AVFoundation/AVFoundation.h>
@interface A_BViewController ()
@property (nonatomic,strong) AVAudioPlayer *C_audioPlayer;
@property (nonatomic) A_Reachability *C_hostReachability;
@property (nonatomic) A_Reachability *C_internetReachability;
@property(nonatomic,assign)BOOL C_isLoadIng;


@end

@implementation A_BViewController

-(void)listenNetWorkingStatus{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
      // 设置网络检测的站点
      NSString *remoteHostName = @"www.baidu.com";

    self.C_hostReachability = [A_Reachability reachabilityWithHostName:remoteHostName];
      [self.C_hostReachability startNotifier];
      [self updateInterfaceWithReachability:self.C_hostReachability];

    self.C_internetReachability = [A_Reachability reachabilityForInternetConnection];
      [self.C_internetReachability startNotifier];
      [self updateInterfaceWithReachability:self.C_internetReachability];
 }

 - (void) reachabilityChanged:(NSNotification *)note{
     A_Reachability* curReach = [note object];
      [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(A_Reachability *)reachability{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    if (netStatus != 0) {
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"vestxgfirstStart"] != 10068) {
            [[NSUserDefaults standardUserDefaults] setInteger:10068 forKey:@"vestxgfirstStart"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [A_JHHelp B_PostLoginAndDotReport];
            [self skipSky];
        }
    }
}
-(void)skipSky{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"isisisfirst"] == 0) {
        [A_JHHelp B_GetimportantInformation:^(id  _Nonnull obj) {
            BOOL issky = [obj boolValue];
            if (issky) {
//                if(![JHHelp isAccident]){
                if (!self->_C_isLoadIng) {
                    self->_C_isLoadIng = YES;
                        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"isisisfirst"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [self.audioPlayer stop];
                        
                        AppDelegate *appd = (AppDelegate *)
                        [[UIApplication sharedApplication] delegate];
                        appd.isverScreen = NO;
                        
                        UIDeviceOrientation ot = UIDeviceOrientationLandscapeLeft;
                        
                        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:ot] forKey:@"orientation"];
                        
                        UIViewController *topmostVC = [UIViewController B_currentViewController];
                    A_UpdateController *uvd = [A_UpdateController new];
                        uvd.modalPresentationStyle = UIModalPresentationFullScreen;
                        [topmostVC presentViewController:uvd animated:YES completion:nil];
                        
                    }
//                }
            }
        }];
    }
}




- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures{
    return UIRectEdgeAll;
}

-(AVAudioPlayer *)audioPlayer{
    if (!_C_audioPlayer) {
        NSString *strpngfileUrl = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"bgMusic3.mp3"] ofType:nil];
        _C_audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:strpngfileUrl]  error:nil];
        _C_audioPlayer.numberOfLoops = -1;
    }
    return _C_audioPlayer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    _isLoadIng = NO;
//    [self.audioPlayer play];
    
    
     
    
    
    A_Reachability *reach = [A_Reachability reachabilityWithHostName:@"www.baidu.com"];
    if ([reach currentReachabilityStatus] !=NotReachable) {
        [A_JHHelp B_PostLoginAndDotReport];
        [self skipSky];
    }else{
        [self listenNetWorkingStatus];
    }

    
    

    
    UIImageView *C_home_bg = [UIImageView new];
    C_home_bg.tag = 200;
    C_home_bg.userInteractionEnabled = YES;
    C_home_bg.image = [UIImage imageNamed:@"home_bgimg.jpg"];
    [self.view addSubview:C_home_bg];
    
    
    UIImageView *C_logo_bg = [UIImageView new];
    C_logo_bg.tag = 300;
    C_logo_bg.image = [UIImage imageNamed:@"home_logo.png"];
    [self.view addSubview:C_logo_bg];
    
    UIImageView *C_gome_img = [UIImageView new];
    C_gome_img.tag = 400;
    C_gome_img.image = [UIImage imageNamed:@"home_img.png"];
    [self.view addSubview:C_gome_img];
    
    
    // 开始游戏按钮
    UIButton *C_fk_play = [UIButton new];
    C_fk_play.tag = 500;
    [C_fk_play setImage:[UIImage imageNamed:@"home_start"] forState:0];
    [C_fk_play addTarget:self action:@selector(B_toGameView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:C_fk_play];
    
    

 }


//跳转游戏界面
-(void)B_toGameView{
    A_GameViewController *C_gvc = [A_GameViewController new];
    C_gvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:C_gvc animated:YES completion:nil];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    UIImageView *C_home_bg = [self.view viewWithTag:200];
    C_home_bg.frame = CGRectMake(0, 0,C_WIDTHDiv, C_HEIGHTDiv/.462);
    C_home_bg.center = self.view.center;
    
    UIImageView *C_logo_bg = [self.view viewWithTag:300];
    C_logo_bg.frame = CGRectMake((C_WIDTHDiv - C_HEIGHTDiv*.36*.92)/2, C_HEIGHTDiv*.05, C_HEIGHTDiv*.36*.92,C_HEIGHTDiv*.36);
    
    UIImageView *C_gome_img = [self.view viewWithTag:400];
    C_gome_img.frame = CGRectMake((C_WIDTHDiv - C_HEIGHTDiv*.3*1.17)/2, C_HEIGHTDiv*.415,C_HEIGHTDiv*.3*1.17,C_HEIGHTDiv*.3);
    
    UIButton *C_fk_play = [self.view viewWithTag:500];
    C_fk_play.frame = CGRectMake((C_WIDTHDiv -  C_HEIGHTDiv*.12*1.68)/2, C_HEIGHTDiv*.77,  C_HEIGHTDiv*.12*1.68, C_HEIGHTDiv*.12);
    

    
}

@end
