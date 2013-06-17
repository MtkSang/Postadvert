//
//  HDBListResultViewController.h
//  Stroff
//
//  Created by Ray on 2/4/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
#import "MyMapViewController.h"
@class MBProgressHUD;
@interface HDBListResultViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, PullRefreshTableViewControllerDelegate, UITabBarDelegate, MyMapViewControllerDelegate>
{
    MBProgressHUD *hud;
    MBProgressHUD *mbpMap;
    NSMutableArray *currentListResult;
    NSMutableArray *currentListForMap;
    NSUInteger totalResultCount;
    NSString *resultType;
    
    NSDictionary *staticData;
    NSMutableArray *mainFiles;
    NSMutableArray *mainFilesValues;
    NSMutableArray *moreOptions;
    NSString *max_id;
    NSString *sortByValue;
    NSString *property_status;
    
    MBProgressHUD *footerLoading;
    MBProgressHUD *loadingHideView;
    
    MyMapViewController *mapView;
    
    UITabBarItem *currentItem;
    BOOL isLoadData;
    BOOL isListView;
}
@property (weak, nonatomic) IBOutlet UIView *flipView;
@property (nonatomic, strong) NSString *itemName;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (strong, nonatomic) IBOutlet PullRefreshTableViewController *pullTableViewCtrl;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbNumFound;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
