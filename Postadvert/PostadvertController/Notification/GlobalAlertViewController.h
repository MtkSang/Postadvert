//
//  GlobalAlertViewController.h
//  Postadvert
//
//  Created by Mtk Ray on 6/27/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIAlertCell.h"
@class MBProgressHUD;
@protocol GlobalAlertViewControllerDelegate;
@interface GlobalAlertViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UIAlertCellDelegate>
{
    id <GlobalAlertViewControllerDelegate> delegate;
    BOOL isDragging;
    BOOL isLoading;
    BOOL isLoadData;
     MBProgressHUD *footerLoading;
    MBProgressHUD *HUD;
    NSMutableArray *listAlertCellContent;
}
@property (weak, nonatomic) IBOutlet UIView *topView;
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

@property (nonatomic, weak) id <GlobalAlertViewControllerDelegate> delegate;
@property ( nonatomic, weak)     IBOutlet UITableView *tableView;
@end
@protocol GlobalAlertViewControllerDelegate <NSObject>
- (void) alertDidSelectedRowWithInfo:(NSDictionary*)info;

@end
