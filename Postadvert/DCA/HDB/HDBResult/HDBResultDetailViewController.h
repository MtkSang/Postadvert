//
//  HDBResultDetailViewController.h
//  Stroff
//
//  Created by Ray on 3/6/13.
//  Copyright (c) 2013 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HBBResultCellData.h"
#import "UIPlaceHolderTextView.h"
@class MBProgressHUD;
@interface HDBResultDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>
{
    MBProgressHUD *hud;
    HBBResultCellData *cellData;
    NSMutableArray *listComments;
}
@property (nonatomic)   NSInteger hdbID;
@property (nonatomic)   NSInteger userID;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSString *property_status;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *texbox;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) BOOL showKeyboard;
- (id)initWithHDBID:(NSInteger) hdbID_ userID:(NSInteger) userID_;
- (IBAction)btnSendClicked:(id)sender;
@end
