//
//  HDBViewController.h
//  Stroff
//
//  Created by Ray on 1/3/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HDBViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    UIButton *leftButton;
    UIButton *rightButton;
    UIButton *currentButton;
    
    NSMutableArray *mainFiles;
    NSMutableArray *moreOptions;
    NSString *keyWorlds;
    NSMutableArray *serachBy;
    NSMutableArray *filters;
}
@property (strong, nonatomic) NSString *itemName;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@end
