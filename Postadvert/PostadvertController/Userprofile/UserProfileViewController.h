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
#import "WEPopoverController.h"
@class CredentialInfo;
#import "UINewStatusViewController.h"
@interface UserProfileViewController :PullRefreshTableViewController<MBProgressHUDDelegate,WEPopoverControllerDelegate, UINewStatusViewControllerDelegate>
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
    UIView *viewUseToGetRectPopover;
    WEPopoverController *popoverController;
}
@property (nonatomic, weak) IBOutlet UIView *headerViewSection;
@property (weak, nonatomic) IBOutlet UIButton *addFriendBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (nonatomic, weak) UINavigationController *navigationController;

- (IBAction)btnPostClicked:(id)sender;
- (void) setLastUserId:(long) userID;
- (id)initWithUserID:(long)userID;
@end
