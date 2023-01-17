//
//  loadGif.m
//  Unity-iPhone
//
//  Created by QPX on 2021/8/9.
//

#import "A_loadGif.h"
#import "UIView+A_Frame.h"
@interface PlayerLoadingView : UIView

@property(nonatomic,copy)NSString *C_nameStr;

@property(nonatomic,assign)int C_IMAGE_COUNT;

@property(nonatomic,assign)int C_speed;

@property(nonatomic,assign)BOOL C_repeat;

@property(nonatomic,copy)CADisplayLink *C_displayLink;

@property(nonatomic,copy)NSMutableArray *C_images;

-(void)B_startLoading;

-(void)B_endLoading;

@property (nonatomic, copy) void(^block)(UIView *view);

@end

@interface PlayerLoadingView ()

@property(nonatomic,assign)int C_index;



@end

@implementation PlayerLoadingView{
    CALayer *C__layer;
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _C_images=[NSMutableArray array];
        
        //创建图像显示图层
        C__layer=[[CALayer alloc]init];
        C__layer.frame=CGRectMake(0, 0, self.C_width, self.C_height);
    //    _layer.position=CGPointMake(0, 0);
        [self.layer addSublayer:C__layer];
    }
    return self;
}

-(void)B_step{
    //定义一个变量记录执行次数
    static int s=0;
    //每秒执行6次
    if (++s%_C_speed==0) {
        UIImage *image=_C_images[_C_index];
        C__layer.contents=(id)image.CGImage;//更新图片
        _C_index=(_C_index+1)%_C_IMAGE_COUNT;
        if(!_C_repeat){
            if(_C_index == _C_IMAGE_COUNT-1){
                _C_displayLink.paused = YES;
                _C_displayLink = nil;
                [_C_images removeAllObjects];
                [_C_displayLink invalidate];
                if(_block){
                    _block(self);
                }
            }
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

-(void)B_startLoading{
    
    for (int i=0; i<_C_IMAGE_COUNT; ++i) {
        NSString *imageName=[NSString stringWithFormat:@"%@%i",_C_nameStr,i];
//        NSLog(@"in:%@",imageName);
        UIImage *image=[UIImage imageNamed:imageName];
        [_C_images addObject:image];
    }
    //定义时钟对象
    _C_displayLink=[CADisplayLink displayLinkWithTarget:self selector:@selector(B_step)];
    //添加时钟对象到主运行循环
    [_C_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void)B_endLoading{
    
}

-(void)dealloc{
    NSLog(@"LoadingView dealloc");
}

@end

@implementation A_loadGif

+(void)B_show:(UIView *)view imgStr:(NSString *)imgStr repeat:(BOOL)repeat speed:(int)speed imgCount:(int)imgCount rect:(CGRect)rect{
    if(![view viewWithTag:767]){
        PlayerLoadingView *_C_plview = [[PlayerLoadingView alloc]initWithFrame:rect];
        _C_plview.C_nameStr = imgStr;
        _C_plview.C_IMAGE_COUNT = imgCount;
        _C_plview.C_speed = speed;
        _C_plview.tag = 767;
        [view addSubview:_C_plview];
        _C_plview.C_repeat = repeat;
        [_C_plview B_startLoading];
    }else{
        PlayerLoadingView *_C_plview = [view viewWithTag:767];
        _C_plview.frame = rect;
        _C_plview.C_nameStr = imgStr;
        _C_plview.C_IMAGE_COUNT = imgCount;
        _C_plview.C_speed = speed;
        _C_plview.tag = 767;
        _C_plview.C_repeat = repeat;
        [_C_plview B_startLoading];
    }
}

+(void)B_show:(UIView *)view imgStr:(NSString *)imgStr repeat:(BOOL)repeat speed:(int)speed imgCount:(int)imgCount rect:(CGRect)rect bolck:(giflock)block{
    if(![view viewWithTag:767]){
        PlayerLoadingView *_C_plview = [[PlayerLoadingView alloc]initWithFrame:rect];
        _C_plview.C_nameStr = imgStr;
        _C_plview.C_IMAGE_COUNT = imgCount;
        _C_plview.C_speed = speed;
        _C_plview.tag = 767;
        _C_plview.block = (^(UIView *view){
            block(view);
        });
        _C_plview.C_repeat = repeat;
        [view addSubview:_C_plview];
        
        [_C_plview B_startLoading];
    }else{
        PlayerLoadingView *_plview = [view viewWithTag:767];
        _plview.frame = rect;
        _plview.C_nameStr = imgStr;
        _plview.C_IMAGE_COUNT = imgCount;
        _plview.C_speed = speed;
        _plview.tag = 767;
        _plview.C_repeat = repeat;
        _plview.block = (^(UIView *view){
            block(view);
        });
        [_plview B_startLoading];
    }
}

+(void)B_cloose:(UIView *)view{
    PlayerLoadingView *_C_plview = [view viewWithTag:767];
    _C_plview.C_displayLink.paused = YES;
    _C_plview.C_displayLink = nil;
    [_C_plview.C_images removeAllObjects];
    [_C_plview.C_displayLink invalidate];
    [_C_plview removeFromSuperview];
}

@end
