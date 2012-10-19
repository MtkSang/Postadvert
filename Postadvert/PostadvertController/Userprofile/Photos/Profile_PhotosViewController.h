//
//  Profile_PhotosViewController.h
//  Stroff
//
//  Created by Ray on 10/17/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface Profile_PhotosViewController : UITableViewController<MBProgressHUDDelegate>
{
    NSMutableArray *listContent;
    UILabel *headerTitle;
    NSString *fullName;
    long userID;
}
@property (nonatomic, weak) UINavigationController *navigationController;
- (id) initWithFullName:(NSString*)name userID:(long) userID_;
@end
