//
//  UserProfileComponentViewController.h
//  Stroff
//
//  Created by Ray on 10/23/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBProgressHUD;
@interface UserProfileComponentViewController : UITableViewController< UISearchBarDelegate, UISearchDisplayDelegate, UISearchDisplayDelegate>
{
    NSInteger previousIndex;
    MBProgressHUD *footerHUD;
    UIActivityIndicatorView *activityView;
    UIView *footerView;
}
@property (strong, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *shortTitle;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)segmentControl:(id)sender;
- (NSString*) shortTitleString;
@end
