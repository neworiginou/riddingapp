//
//  InvitationViewController.h
//  Ridding
//
//  Created by Wu Chenhao on 6/26/12.
//  Copyright (c) 2012 MicroStrategy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "SinaUserProfile.h"
#import "InvitationViewCell.h"
@interface InvitationViewController : BasicViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,InvitationViewCellDelegate> {
  long long _riddingId;
  NSMutableArray *_nowUser;
  NSMutableDictionary *_originUser;
  BOOL _isSearching;
  NSMutableArray *_sinaUsers;
}

@property (nonatomic, retain) IBOutlet UITableView *atableView;
@property (nonatomic, retain) IBOutlet UITextField *searchField;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil riddingId:(long long)riddingId nowTeamers:(NSArray *)nowTeamers;
@end
