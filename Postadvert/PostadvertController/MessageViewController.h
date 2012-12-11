//
//  MessageViewController.h
//  Postadvert
//
//  Created by Mtk Ray on 6/28/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@protocol MessageViewControllerDelegate;
@interface MessageViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, MBProgressHUDDelegate>
{
    id <MessageViewControllerDelegate> delegate;
    NSMutableArray *listMessageCellContent;
    NSMutableArray *filteredListContent;
    //UINavigationController *navigationController;
    MBProgressHUD *hud;
}
//@property (nonatomic, strong) NSMutableArray *listMessageCellContent;
//@property (nonatomic, strong) NSMutableArray *filteredListContent;
@property (nonatomic, weak) id <MessageViewControllerDelegate> delegate;
@property (nonatomic, weak) UINavigationController *navigationController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@protocol MessageViewControllerDelegate
- (void) searchDisplayControllerDidEnterSearch;
- (void) searchDisplayControllerDidGoAwaySearch;
- (void) messageViewControllerDidSelectedRowWithInfo:(NSDictionary*)info;
@end