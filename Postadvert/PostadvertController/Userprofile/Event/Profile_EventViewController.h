//
//  Profile_EventViewController.h
//  Stroff
//
//  Created by Ray on 10/26/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserProfileComponentViewController.h"
@interface Profile_EventViewController : UserProfileComponentViewController
{
    NSMutableArray *listContent_my;
    NSMutableArray *listContent_all;
    NSMutableArray *listContent_past;
    NSMutableArray *listContent_invition;
    NSMutableArray *filteredListContent;
    NSThread *searchThread;
    NSString *fullName;
    UITableView *searchTable;
    long userID;
    NSInteger searchCount;}
@property (nonatomic, weak) UINavigationController *navigationController;
- (id) initWithFullName:(NSString*)name userID:(long) userID_;
@end
