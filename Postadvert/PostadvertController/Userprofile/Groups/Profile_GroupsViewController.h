//
//  Profile_GroupsViewController.h
//  Stroff
//
//  Created by Ray on 10/22/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "UserProfileComponentViewController.h"
@interface Profile_GroupsViewController : UserProfileComponentViewController<MBProgressHUDDelegate>
{
    NSMutableArray *listContent_my;
    NSMutableArray *listContent_all;
    NSMutableArray *listContent_invition;
    NSMutableArray *filteredListContent;
    NSThread *searchThread;
    NSString *fullName;
    long userID;
    NSInteger searchCount;
}
@property (nonatomic, weak) UINavigationController *navigationController;
- (id) initWithFullName:(NSString*)name userID:(long) userID_;
@end
