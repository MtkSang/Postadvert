//
//MyQ_AViewController.h
//  Stroff
//
//  Created by Ray on 7/11/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullRefreshTableViewController.h"
@class MBProgressHUD;
@class MyQ_AViewController;
@class UILable_Margin;
@class UIPlaceHolderTextView;
enum MyQ_AType {
    myQ_A = 1,
    askQ_A = 2,
    browse = 3
};
@interface MyQ_AViewController :  UIViewController<UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, PullRefreshTableViewControllerDelegate>
{
    MBProgressHUD *hud;
    NSMutableArray *listMyQ_A;
    BOOL isLoadData;
    MBProgressHUD *footerLoading;
    MBProgressHUD *loadingHideView;
    MBProgressHUD *mbpLoadQ_A;
    NSMutableArray *listCategoriesAskQ_A;
    NSMutableArray *listLocationsAskQ_A;
    
}
@property (nonatomic) enum MyQ_AType type;
@property (strong, nonatomic) NSString *itemName;
@property (strong, nonatomic) NSString *itemBarName;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (strong, nonatomic) IBOutlet UITableViewCell *askQnCell;
@property (strong, nonatomic) IBOutlet UITextField *askQnTextField;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *placeTextAskQn;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILable_Margin *lbQ_A;
@property (strong, nonatomic) IBOutlet PullRefreshTableViewController *pullTableViewCtrl;
@end
