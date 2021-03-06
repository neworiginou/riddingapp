//
//  RiddingAppDelegate.m
//  Ridding
//
//  Created by zys on 12-3-19.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "LandingViewController.h"
#import "MyLocationManager.h"
#import "QQNRFeedViewController.h"
#import "RiddingPictureDao.h"
#import "Gps.h"
#import "Utilities.h"
#import "GpsDao.h"
#import "PSLocationManager.h"
#include <stdio.h>
#define moveSpeed 0.5
@interface RiddingAppDelegate(){
  
  
}
@end;
@implementation RiddingAppDelegate
@synthesize window = _window;
@synthesize rootViewController = _rootViewController;
@synthesize navController = _navController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  [MobClick startWithAppkey:YouMenAppKey reportPolicy:REALTIME channelId:nil];
  [MobClick updateOnlineConfig];
  [[ResponseCodeCheck getSinglton] checkConnect];
 
   //检查网络
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self setUserInfo];
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  if([prefs boolForKey:kStaticInfo_StartApp]){
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];
  }
  
  if([self canLogin]){
    
    self.rootViewController= [[QQNRFeedViewController alloc]initWithUser:[StaticInfo getSinglton].user isFromLeft:YES];
    
  }else{
    
    self.rootViewController = [[PublicViewController alloc] init];
  }

  
  self.navController = [[UINavigationController alloc] initWithRootViewController:self.rootViewController];
  
  self.navController.navigationBar.hidden = YES;
  self.window.rootViewController = self.navController;
  
  
  self.leftViewController = [[BasicLeftViewController alloc] init];
  self.leftViewController.view.frame = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT);
  
  [self.window addSubview:self.leftViewController.view];
  [self.window addSubview:self.navController.view];
  
  [self.window makeKeyAndVisible];
  
  
  if(![prefs boolForKey:kStaticInfo_StartApp]){
    LandingViewController *landingViewController=[[LandingViewController alloc]init];
    [self.rootViewController presentModalViewController:landingViewController animated:NO];
    [prefs setBool:YES forKey:kStaticInfo_StartApp];
    
  }
  [self checkDBUpdate];
  [self firstInit];
  
  // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
	 (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
  return YES;
}

- (void)firstInit{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSString *version=[Utilities appVersion];
  //如果是当前版本的第一次登陆
  if(![prefs boolForKey:version]){
    
    [prefs setBool:YES forKey:kStaticInfo_SaveInWifi];
    [prefs synchronize];
    
  }
}

- (void)checkDBUpdate{
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  NSString *version=[Utilities appVersion];
  if(![prefs boolForKey:version]){
    FMDatabase *db = [StaticInfo getSinglton].sqlDB;
    
    if([version compare:@"1.3"]==NSOrderedDescending){
      
      [db executeUpdate:@"CREATE TABLE \"TB_Gps1\" (\"id\" INTEGER PRIMARY KEY  NOT NULL ,\"latitude\" DOUBLE NOT NULL  DEFAULT (0.0) ,\"longtitude\" DOUBLE NOT NULL  DEFAULT (0.0) ,\"riddingId\" INTEGER,\"userId\" INTEGER,\"fixedLatitude\" double,\"fixedLongtitude\" double),\"altitude\" double, \"speed\" DOUBLE"];
      
      [db executeUpdate:@"CREATE TABLE \"TB_RiddingMapPoint\" (\"id\" INTEGER PRIMARY KEY  NOT NULL , \"riddingid\" INTEGER, \"userid\" INTEGER, \"mappoint\" TEXT)"];
      [db executeUpdate:@"CREATE INDEX index_RiddingMapPoint on \"TB_RiddingMapPoint\" (riddingid,userid)"];
      
    }
  }
}

- (void)setUserInfo {
  
  StaticInfo *staticInfo = [StaticInfo getSinglton];
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  staticInfo.user.userId = [[prefs stringForKey:kStaticInfo_userId] longLongValue];
  staticInfo.user.authToken = [prefs stringForKey:kStaticInfo_authToken];
  staticInfo.user.sourceUserId = [[prefs stringForKey:kStaticInfo_accessUserId] longLongValue];
  staticInfo.user.accessToken = [prefs stringForKey:kStaticInfo_accessToken];
  staticInfo.user.sourceType = [prefs integerForKey:kStaticInfo_sourceType];
  staticInfo.user.taobaoCode= [prefs stringForKey:kStaticInfo_taobaoCode];
  staticInfo.user.backGroundUrl = [prefs stringForKey:kStaticInfo_backgroundUrl];
  staticInfo.user.totalDistance = [prefs integerForKey:kStaticInfo_totalDistance];
  staticInfo.user.name = [prefs objectForKey:kStaticInfo_nickname];
  staticInfo.user.savatorUrl = [prefs objectForKey:kStaticInfo_savatorUrl];
  staticInfo.user.bavatorUrl = [prefs objectForKey:kStaticInfo_bavatorUrl];
}

- (BOOL)canLogin {
  
  StaticInfo *staticInfo = [StaticInfo getSinglton];
  
  if (staticInfo.logined) {
    return TRUE;
  }
  RequestUtil *requestUtil = [[RequestUtil alloc] init];
  NSDictionary *userProfileDic = [requestUtil getUserProfile:staticInfo.user.userId sourceType:staticInfo.user.sourceType needCheckRegister:YES];
  User *user = [[User alloc] initWithJSONDic:[userProfileDic objectForKey:keyUser]];
  //如果新浪成功，并且authtoken有效
  if (staticInfo.user.accessToken != nil && userProfileDic != nil) {
    staticInfo.user.name = user.name;
    staticInfo.user.bavatorUrl = user.bavatorUrl;
    staticInfo.user.savatorUrl = user.savatorUrl;
    staticInfo.user.totalDistance = user.totalDistance;
    staticInfo.user.nowRiddingCount = user.nowRiddingCount;
    staticInfo.user.backGroundUrl = user.backGroundUrl;
    staticInfo.user.taobaoCode=user.taobaoCode;
    staticInfo.logined = TRUE;
    return TRUE;
  }
  return FALSE;
}

+ (BOOL)isMyFeedHome:(User *)user {
  
  if([StaticInfo getSinglton].user.userId<=0){
    return FALSE;
  }
  if ([StaticInfo getSinglton].user && [StaticInfo getSinglton].user.userId == user.userId ) {
    return TRUE;
  }
  return FALSE;
}




//iPhone 从APNs服务器获取deviceToken后回调此方法
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
  
  NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  [prefs setObject:dt forKey:kStaticInfo_apnsToken];
  if([StaticInfo getSinglton].logined){
    RequestUtil *requestUtil=[[RequestUtil alloc]init];
    [requestUtil sendApns];
  }
}

//注册push功能失败 后 返回错误信息，执行相应的处理
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
  
  
}

+ (RiddingAppDelegate *)shareDelegate {
  
  return (RiddingAppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (void)applicationWillResignActive:(UIApplication *)application {
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

//进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application {
  PSLocationManager *locationManager=[PSLocationManager sharedLocationManager];
  [locationManager startBackgroundLocation];
}

//回到前台
- (void)applicationWillEnterForeground:(UIApplication *)application {
  
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
  PSLocationManager *locationManager=[PSLocationManager sharedLocationManager];
  [locationManager stopBackgroundLocation];

}

- (void)applicationWillTerminate:(UIApplication *)application {
  
  PSLocationManager *locationManager=[PSLocationManager sharedLocationManager];
  [locationManager stopBackgroundLocation];
  
}


+ (void)moveMidNavgation {
  
  RiddingAppDelegate *delegate = [RiddingAppDelegate shareDelegate];
  
  //往左移动
  [UIView animateWithDuration:moveSpeed animations:^{
    delegate.navController.view.frame = CGRectMake(LeftBarMoveWidth,
                                                   delegate.navController.view.frame.origin.y,
                                                   delegate.navController.view.frame.size.width,
                                                   delegate.navController.view.frame.size.height);
    
  }
                   completion:^(BOOL finish) {
                     ((BasicViewController *) delegate.navController.visibleViewController).position = POSITION_MID;
                     [delegate.leftViewController showShadow];
                   }];
  
}

+ (void)moveLeftNavgation {
  
  RiddingAppDelegate *delegate = [RiddingAppDelegate shareDelegate];
  //往左移动
  [UIView animateWithDuration:moveSpeed animations:^{
    delegate.navController.view.frame = CGRectMake(0,
                                                   delegate.navController.view.frame.origin.y,
                                                   delegate.navController.view.frame.size.width,
                                                   delegate.navController.view.frame.size.height);
    
  }
                   completion:^(BOOL finish) {
                     ((BasicViewController *) delegate.navController.visibleViewController).position = POSITION_LEFT;
                   }];
}

+ (void)moveRightNavgation {
  
  RiddingAppDelegate *delegate = [RiddingAppDelegate shareDelegate];
  //往右移动
  [UIView animateWithDuration:moveSpeed animations:^{
    delegate.navController.view.frame = CGRectMake(SCREEN_WIDTH,
                                                   delegate.navController.view.frame.origin.y,
                                                   delegate.navController.view.frame.size.width,
                                                   delegate.navController.view.frame.size.height);
    
  }
                   completion:^(BOOL finish) {
                     ((BasicViewController *) delegate.navController.visibleViewController).position = POSITION_RIGHT;
                     
                   }];
}

+ (void)popAllNavgation {
  
  RiddingAppDelegate *delegate = [RiddingAppDelegate shareDelegate];
  [delegate.navController popToRootViewControllerAnimated:NO];
  [delegate.navController popViewControllerAnimated:NO];
}


@end
