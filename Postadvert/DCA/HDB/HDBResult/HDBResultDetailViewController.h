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
#import "MyMapViewController.h"
@class UploadImagesViewController;
@class MBProgressHUD;
@class MyMapViewController;
@class NWViewLocationController;
@interface HDBResultDetailViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UITabBarDelegate, MyMapViewControllerDelegate>
{
    MBProgressHUD *hud;
    MBProgressHUD *mbpMap;
    HBBResultCellData *cellData;
    NSMutableArray *listComments;
    UITabBarItem *currentItem;
    NSArray *_paraValues;
    NSArray *_paraNames;
    UploadImagesViewController* uploadImagesView;
    MyMapViewController *mapView;
    NWViewLocationController *streetView;
    NSMutableArray *listPlacemarks;
}
@property (nonatomic)   NSInteger hdbID;
@property (nonatomic)   NSInteger userID;
@property (nonatomic)   NSInteger viewMode;
@property (nonatomic, strong) NSArray *sourceForPreviewMode;
@property (nonatomic, strong) NSArray *listImages;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;
@property (nonatomic, strong) NSString *property_status;
@property (nonatomic, strong) NSString *itemName;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *texbox;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic) BOOL showKeyboard;
- (id)initWithHDBID:(NSInteger) hdbID_ userID:(NSInteger) userID_;
- (id)initBySubmitParaNames:(NSArray*)paranames andParavalues:(NSArray*)paravalues withListImages:(NSArray*)listimages;
- (IBAction)btnSendClicked:(id)sender;
@end

