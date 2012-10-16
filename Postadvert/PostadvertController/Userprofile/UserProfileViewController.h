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
@interface UserProfileViewController :PullRefreshTableViewController<MBProgressHUDDelegate>
{
    NSMutableArray *listContent;
    NSMutableArray *listActivityCell;
    //IBOutlet UIView *headerViewSection;
    IBOutlet UIScrollView   *scrollingBar;
    IBOutlet UIImageView    *userAvatar;
    IBOutlet UILabel        *userFullName;
    IBOutlet UILabel        *userName;
    MBProgressHUD *footerLoading;
    MBProgressHUD *HUD;
    BOOL isLoadData;
    long lastUserId;
    
}
@property (nonatomic, weak) IBOutlet UIView *headerViewSection;
@property (nonatomic, weak) UINavigationController *navigationController;
@end
