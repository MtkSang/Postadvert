//
//  GlobalNotificationsViewController.h
//  Postadvert
//
//  Created by Mtk Ray on 6/26/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UINotificationsCell.h"
@class MBProgressHUD;
@protocol GlobalNotificationsViewControllerDelegate;
@interface GlobalNotificationsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UINotificationsCellDelegate>
{
    id <GlobalNotificationsViewControllerDelegate> delegate;
    IBOutlet UILabel *titleMessage;
    IBOutlet UIView* topView;
    BOOL isDragging;
    BOOL isLoading;
    BOOL isLoadData;
    MBProgressHUD *footerLoading;
    NSMutableArray *listNotificationsCellContent;
    MBProgressHUD *HUD;
}


@property (nonatomic, strong) UIView *refreshHeaderView;
@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UIImageView *refreshArrow;
@property (nonatomic, strong) UIActivityIndicatorView *refreshSpinner;
@property (nonatomic, copy) NSString *textPull;
@property (nonatomic, copy) NSString *textRelease;
@property (nonatomic, copy) NSString *textLoading;

- (void)setupStrings;
- (void)addPullToRefreshHeader;
- (void)startLoading;
- (void)stopLoading;
- (void)refresh;

@property (nonatomic, weak) id <GlobalNotificationsViewControllerDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIView* topView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@protocol GlobalNotificationsViewControllerDelegate <NSObject>
- (void) didSelectedRowWithInfo:(NSDictionary*)info;

@end
