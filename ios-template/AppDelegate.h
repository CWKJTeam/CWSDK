#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate,AppsFlyerLibDelegate,UNUserNotificationCenterDelegate>
@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,copy)NSString *arguments;

@property(nonatomic,assign)BOOL isverScreen;

@end
