//
//  HDBListResultViewController.h
//  Stroff
//
//  Created by Ray on 2/4/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
@class MBProgressHUD;
@interface HDBListResultViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PullRefreshTableViewControllerDelegate>
{
    MBProgressHUD *hud;
    NSMutableArray *currentListResult;
    NSUInteger totalResultCount;
    NSString *resultType;
    
    NSDictionary *staticData;
    NSMutableArray *mainFiles;
    NSMutableArray *mainFilesValues;
    NSMutableArray *moreOptions;
    NSString *sortByValue;
    NSString *property_status;
    
    MBProgressHUD *footerLoading;
    MBProgressHUD *loadingHideView;
    BOOL isLoadData;
}
@property (strong, nonatomic) IBOutlet PullRefreshTableViewController *pullTableViewCtrl;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbNumFound;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
