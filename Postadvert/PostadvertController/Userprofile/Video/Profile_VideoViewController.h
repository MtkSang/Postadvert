//
//  Profile_VideoViewController.h
//  Stroff
//
//  Created by Ray on 10/16/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "UserProfileComponentViewController.h"

@interface Profile_VideoViewController : UserProfileComponentViewController<MBProgressHUDDelegate>
{
    NSMutableArray *listContent_my;
    NSMutableArray *listContent_all;
    NSMutableArray *filteredListContent;
    NSThread *searchThread;
    NSString *fullName;
    long userID;
    NSInteger searchCount;
}
- (id) initWithFullName:(NSString*)name userID:(long) userID_;
@end
