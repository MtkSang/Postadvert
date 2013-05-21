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
@class UploadImagesViewController;
@class MBProgressHUD;
@interface HDBResultDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITabBarDelegate>
{
    MBProgressHUD *hud;
    HBBResultCellData *cellData;
    NSMutableArray *listComments;
    UITabBarItem *currentItem;
    NSArray *_paraValues;
    NSArray *_paraNames;
    NSArray *_listImages;
    UploadImagesViewController* uploadImagesView;
}
@property (nonatomic)   NSInteger hdbID;
@property (nonatomic)   NSInteger userID;
@property (nonatomic)   NSInteger viewMode;
@property (nonatomic, strong) NSArray *sourceForPreviewMode;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (nonatomic, strong) NSString *property_status;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *texbox;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) BOOL showKeyboard;
- (id)initWithHDBID:(NSInteger) hdbID_ userID:(NSInteger) userID_;
- (id)initBySubmitParaNames:(NSArray*)paranames andParavalues:(NSArray*)paravalues withListImages:(NSArray*)listimages;
- (IBAction)btnSendClicked:(id)sender;
@end
