//
//  HDBListResultViewController.h
//  Stroff
//
//  Created by Ray on 2/4/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBProgressHUD;
@interface HDBListResultViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
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
}
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbNumFound;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
