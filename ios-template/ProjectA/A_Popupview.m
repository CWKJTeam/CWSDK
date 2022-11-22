#import "A_Popupview.h"

@interface A_tipFailureView : UIView

@property(nonatomic,copy)void(^block)(int C_tag);

@end

@interface A_tipFailureView()

@end


@implementation A_tipFailureView

-(instancetype)initWithInfo:(int)winType title:(NSString*)title
{
    if (self = [self init])
    {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.5];
        self.frame = CGRectMake(0, 0, WIDTHDiv, HEIGHTDiv);
        
        UIImageView *C_bgimg = [UIImageView new];
        C_bgimg.tag = 200;
        C_bgimg.image = [UIImage imageNamed:@"home_bgimg.jpg"];
        [self addSubview:C_bgimg];
        
        
        UIImageView *C_logo = [UIImageView new];
        C_logo.tag = 300;
        C_logo.image = [UIImage imageNamed:@"popu_logo"];
        [self addSubview:C_logo];
       
        
        UIButton *C_rebtn = [UIButton new];
        C_rebtn.tag = 1000;
        C_rebtn.userInteractionEnabled = YES;
        [C_rebtn setImage:[UIImage imageNamed:@"popu_regame.png"] forState:0];
        [C_rebtn addTarget:self action:@selector(B_btn_Click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:C_rebtn];
        
    }
    return  self;
}
-(void)B_btn_Click:(UIButton *)C_sender{
    if (_block) {
        _block((int)C_sender.tag-1000);
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    UIImageView *C_bgimg = [self viewWithTag:200];
    C_bgimg.frame = CGRectMake(0, 0, WIDTHDiv,HEIGHTDiv);
    
    UIImageView *C_logo = [self viewWithTag:300];
    C_logo.frame = CGRectMake((WIDTHDiv - HEIGHTDiv*.25*1.55)/2, HEIGHTDiv*.25,HEIGHTDiv*.25*1.55,HEIGHTDiv*.25);
   
    UIImageView *C_rebtn = [self viewWithTag:1000];
    C_rebtn.frame =  CGRectMake((WIDTHDiv -  HEIGHTDiv*.12*1.68)/2, HEIGHTDiv*.6,  HEIGHTDiv*.12*1.68, HEIGHTDiv*.12);
}

@end



@implementation A_Popupview

+(void)B_showFailure:(int)failureType title:(NSString *)title view:(UIView*)view btnblock:(winblock)block
{
    A_tipFailureView *C_tView = [[A_tipFailureView alloc]initWithInfo:failureType title:title];
    C_tView.block = (^(int tag){
        block(tag);
    });
    [view addSubview:C_tView];
    
}

@end
