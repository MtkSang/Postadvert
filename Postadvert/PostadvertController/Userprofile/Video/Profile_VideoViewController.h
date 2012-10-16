//
//  Profile_VideoViewController.h
//  Stroff
//
//  Created by Ray on 10/16/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface Profile_VideoViewController : UITableViewController<MBProgressHUDDelegate>
{
    NSMutableArray *listContent;
    UILabel *headerTitle;
}
@end
