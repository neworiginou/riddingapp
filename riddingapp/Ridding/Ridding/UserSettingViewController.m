//
//  UserSettingViewController.m
//  Ridding
//
//  Created by zys on 12-5-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserSettingViewController.h"
#import "UMFeedback.h"
#import "TutorialViewController.h"
#import "UIColor+XMin.h"
#import "SinaApiRequestUtil.h"

@implementation UserSettingViewController
@synthesize uiTableView=_uiTableView;
@synthesize staticInfo;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        staticInfo=[StaticInfo getSinglton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.barView.titleLabel.text=@"设置";
    
    [self.uiTableView setBackgroundColor:[UIColor getColor:@"E6E6E6"]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  self.navigationController.navigationBar.hidden=YES;
    
}
- (void)viewWillDisappear:(BOOL)animated
{
   	[super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait||interfaceOrientation ==UIInterfaceOrientationPortraitUpsideDown);
}
#pragma mark -
#pragma mark UITableView data source and delegate methods
//每个section显示的标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"";
}

//指定有多少个分区(Section)，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if(section == 0){
        return 4;//推荐、帮助、升级
    }
    if(section == 1){
        return 1;//退出,注销
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{	
    static NSString *kCellID = @"CellID";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
	}
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if([indexPath section]==0){
        if([indexPath row]==0){
            cell.textLabel.text=@"还没有骑行活动?";
        }else if([indexPath row]==1){
            cell.textLabel.text=@"喜欢这款应用吗?";
        }else if([indexPath row]==2){
            cell.textLabel.text=@"一起来设计骑行者";
        }else if([indexPath row]==3){
            cell.textLabel.text=@"查看新版本!有惊喜!";
        }
    }else if([indexPath section]==1){
        if([indexPath row]==0){
            cell.textLabel.text = @"退出";
        }
    }
    cell.imageView.frame=CGRectMake(cell.imageView.frame.origin.x, cell.imageView.frame.origin.y, 20, 20);
    cell.textLabel.textColor = [UIColor getColor:@"303030"];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

-(void)quitButtonClick{
  SinaApiRequestUtil* requestUtil=[SinaApiRequestUtil getSinglton];
  [requestUtil quit];
  [SFHFKeychainUtils deleteItemForUsername:staticInfo.user.userId andServiceName:@"riddingapp" error:nil];
  staticInfo.user.userId=@"";
  staticInfo.user.accessToken=@"";
  staticInfo.user.authToken=@"";
  staticInfo.logined=false;
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  [prefs removeObjectForKey:@"userId"];
  [prefs removeObjectForKey:@"nickname"];
  [prefs removeObjectForKey:@"authToken"];
  [prefs removeObjectForKey:@"sourceType"];
  [prefs removeObjectForKey:@"recomApp"];
  [prefs removeObjectForKey:@"accessToken"];
  [prefs removeObjectForKey:@"riddingCount"];
  [prefs removeObjectForKey:@"accessUserId"];
  RiddingViewController *view=[[RiddingViewController alloc]init];
  RiddingAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  appDelegate.rootViewController=view;
  [self.navigationController popToRootViewControllerAnimated:NO];
  // 清空通知中心和badge
  
  // 清除badge
  [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath section]==0){
        if([indexPath row]==0){
          MapCreateVCTL *mapCreate=[[MapCreateVCTL alloc]init];
          mapCreate.delegate=self;
          [self presentModalViewController:mapCreate animated:YES];
        }else if([indexPath row]==1){  
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkAppStoreComment]];
        }else if([indexPath row]==2){
          NSDictionary  *info=[[NSDictionary alloc]initWithObjectsAndKeys:staticInfo.user.userId,@"userid",staticInfo.user.name,@"nickname", nil];
            [UMFeedback showFeedback:self withAppkey:@"4fb3ce805270152b53000128" dictionary:info];
            self.navigationController.navigationBarHidden = NO;
        }else if([indexPath row]==3){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:linkAppStore]];
        }
    }else if([indexPath section]==1){
        if([indexPath row]==0){
            SinaApiRequestUtil* requestUtil=[SinaApiRequestUtil getSinglton];
            [requestUtil quit];
            [self quitButtonClick];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
#pragma mark -
#pragma mark Table Delegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath { 
    return UITableViewCellEditingStyleNone; 
}
#pragma mark -
#pragma mark MapCreateVCTL delegate
- (void)finishCreate:(MapCreateVCTL*)controller info:(MapCreateInfo*)info{
  [controller dismissModalViewControllerAnimated:YES];
}
@end
