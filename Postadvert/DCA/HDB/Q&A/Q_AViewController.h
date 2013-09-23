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
@class MyQ_AViewController;
enum Q_AType {
    Q_ALastestAnswer = 0,
    Q_APopularQuestion = 1
};
@class Q_ACellDetailViewController;

@interface Q_AViewController :  UIViewController<UITableViewDataSource, UITableViewDelegate, UITabBarDelegate>
{
    MBProgressHUD *hud;
    UIButton *currentButton;
    NSMutableArray *listLastestAnswers;
    BOOL isLoadData;
    MBProgressHUD *footerLoading;
    MBProgressHUD *loadingHideView;
    enum Q_AType q_aType;
    MBProgressHUD *mbpLastest;
    
    MyQ_AViewController *myQ_A;
    Q_ACellDetailViewController *cellDetailViewCtr;
}
@property (strong, nonatomic) NSString *itemName;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (strong, nonatomic) IBOutlet PullRefreshTableViewController *pullTableViewCtrl;
@end
