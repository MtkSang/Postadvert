//
//  Q_AViewController.h
//  Stroff
//
//  Created by Ray on 7/11/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
@class MBProgressHUD;
enum Q_AType {
    Q_ALastestAnswer = 0,
    Q_APopularQuestion = 1
}; 

@interface Q_AViewController :  UIViewController<UITableViewDataSource, UITableViewDelegate, PullRefreshTableViewControllerDelegate, UITabBarDelegate>
{
    MBProgressHUD *hud;
    UIButton *currentButton;
    NSMutableArray *listLastestAnswers;
    BOOL isLoadData;
    MBProgressHUD *footerLoading;
    MBProgressHUD *loadingHideView;
    enum Q_AType q_aType;
    MBProgressHUD *mbpLastest;
}
@property (strong, nonatomic) NSString *itemName;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) IBOutlet PullRefreshTableViewController *pullTableViewCtrl;
@end
