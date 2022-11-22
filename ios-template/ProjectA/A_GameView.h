//
//  GameView.h
//  EmptyProj
//
//  Created by 钟志南志南 on 2022/10/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GameViewdelegate <NSObject>

@optional

-(void)B_rehome;
-(void)B_regame;
-(void)B_nextlevel;

@end


@interface A_GameView : UIView

@property(nonatomic,assign)NSInteger C_level;
@property(nonatomic,weak)id <GameViewdelegate>deledete;

@end

NS_ASSUME_NONNULL_END
