//
//  ChatViewController.h
//  Postadvert
//
//  Created by Mtk Ray on 6/20/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WEPopoverController.h"
#import "TakePhotoViewController.h"
@class MessageCellContent;
@class UIPlaceHolderTextView;
#import "MBProgressHUD.h"
@interface ChatViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, WEPopoverControllerDelegate, TakePhotoViewControllerDelegate, MBProgressHUDDelegate>
{
//    IBOutlet UITableView *_tableView;
//    IBOutlet UIView *botView;
//    IBOutlet UIPlaceHolderTextView *message;
//    IBOutlet UIButton *btnSend;
//    IBOutlet UIButton *btnPickPicture;
    UIBarButtonItem *rightNaviBar;
    UIBarButtonItem *leftBarBtnItem;
    UIBarButtonItem *preRightNaviBar;
    NSMutableArray *listMessageCellContent;
    WEPopoverController *popoverController;
    MessageCellContent *infoChatting;
    UIImage *imageAttachment;
    MBProgressHUD    *hud;
}
@property (nonatomic, strong) MessageCellContent *infoChatting;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *botView;
@property (weak, nonatomic) IBOutlet UIButton *btnPickPicture;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIPlaceHolderTextView *message;

- (IBAction) buttonSendClicked:(id)sender;
- (void) loadListMessageCellContent;
- (id) initWithInfo:(MessageCellContent*)info;
@end
