//
//  UserProfileViewController.h
//  Postadvert
//
//  Created by Ray on 9/12/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "PullRefreshTableViewController.h"
@class CredentialInfo;
@interface UserProfileViewController :PullRefreshTableViewController<MBProgressHUDDelegate>
{
    NSMutableArray *listContent;
    NSMutableArray *listActivityCell;
    CredentialInfo *userInfo;
    //IBOutlet UIView *headerViewSection;
    IBOutlet UIScrollView   *scrollingBar;
    IBOutlet UIImageView    *userAvatar;
    IBOutlet UILabel        *userFullName;
    IBOutlet UILabel        *userName;
    MBProgressHUD *footerLoading;
    MBProgressHUD *HUD;
    BOOL isLoadData;
    long    lastUserId;
}
@property (nonatomic, weak) IBOutlet UIView *headerViewSection;
@property (weak, nonatomic) IBOutlet UIButton *addFriendBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (nonatomic, weak) UINavigationController *navigationController;

- (void) setLastUserId:(long) userID;
- (id)initWithUserID:(long)userID;
@end
