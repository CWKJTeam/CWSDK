//
//  GameViewController.m
//  EmptyProj
//
//  Created by 钟志南志南 on 2022/10/13.
//

#import "A_GameViewController.h"
#import "A_GameView.h"
#import "A_BViewController.h"
@interface A_GameViewController ()<GameViewdelegate>

@property(nonatomic,strong)A_GameView *C_gameview;

@end

@implementation A_GameViewController

-(A_GameView*)C_gameview{
    if(!_C_gameview){
        _C_gameview = [A_GameView new];
        _C_gameview.deledete = self;
    }
    return _C_gameview;
}


- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIImageView *C_home_bg = [UIImageView new];
    C_home_bg.tag = 200;
    C_home_bg.userInteractionEnabled = YES;
    C_home_bg.image = [UIImage imageNamed:@"home_bgimg.jpg"];
    [self.view addSubview:C_home_bg];
    
    
    [self.view addSubview:self.C_gameview];
    _C_gameview.C_level = _C_level;
    
}

-(void)B_rehome{
    A_BViewController *C_gvc = [A_BViewController new];
    C_gvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:C_gvc animated:YES completion:nil];
}

-(void)B_regame{
    A_GameViewController *C_gvc = [A_GameViewController new];
    C_gvc.C_level = _C_level;
    C_gvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:C_gvc animated:YES completion:nil];
}

-(void)B_nextlevel{
    A_GameViewController *C_gvc = [A_GameViewController new];
    C_gvc.C_level = _C_level+1;
    C_gvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:C_gvc animated:YES completion:nil];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
        
    UIImageView *C_game_bg = [self.view viewWithTag:200];
    C_game_bg.frame = CGRectMake(0, 0, WIDTHDiv, WIDTHDiv/.462);
    C_game_bg.center = self.view.center;

    
    _C_gameview.frame = CGRectMake(0, 0, WIDTHDiv,HEIGHTDiv);
}
@end
