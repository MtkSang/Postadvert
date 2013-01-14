//
//  HDBViewController.h
//  Stroff
//
//  Created by Ray on 1/3/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDBViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    UIButton *leftButton;
    UIButton *rightButton;
    UIButton *currentButton;
    
    NSDictionary *staticData;
    NSMutableArray *mainFiles;
    NSMutableArray *mainFilesValues;
    NSMutableArray *moreOptions;
    NSString *keyWorlds;
    NSMutableArray *searchBy;
    NSMutableArray *filters;
    NSInteger internalItemID;
}
@property (strong, nonatomic) NSString *itemName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (strong, nonatomic) IBOutlet UITableViewCell *CellWithSearchBar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@end
