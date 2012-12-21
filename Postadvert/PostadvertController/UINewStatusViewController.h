//
//  UINewStatusViewController.h
//  Stroff
//
//  Created by Ray on 12/12/12.
//  Copyright (c) 2012 Futureworkz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIImagePickerViewController.h"
@protocol UINewStatusViewControllerDelegate;
@class UIPlaceHolderTextView;
@class CredentialInfo;
@class LinkPreview;

@interface UINewStatusViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MyUIImagePickerViewControllerDelegate, UIActionSheetDelegate>
{
    CredentialInfo *userInfo;
    UIButton *activeBtn;
    UIView *activeControll;
    NSInteger permittionIndex;
    BOOL    hasPhoto;
    BOOL    hasVideo;
}
@property (weak, nonatomic) id <UINewStatusViewControllerDelegate> delegate;
@property (nonatomic) NSInteger targetID;
@property (strong, nonatomic) IBOutlet UIView *middleView;
@property (strong, nonatomic) IBOutlet UIView *botView;
@property (strong, nonatomic) IBOutlet UIButton *btnStatus;
@property (strong, nonatomic) IBOutlet UIButton *btnPhotos;
@property (strong, nonatomic) IBOutlet UIButton *btnVideos;
@property (strong, nonatomic) IBOutlet UIButton *btnEvents;
@property (strong, nonatomic) IBOutlet UIImageView *userAvatar;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *phStatusTextView;
@property (strong, nonatomic) IBOutlet UITableView *permissionTableView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *shareBtn;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *usernameBtn;
@property (strong, nonatomic) IBOutlet UIButton *btnPermittion;
@property (strong, nonatomic) IBOutlet UIImageView *imgPhoto;
@property (strong, nonatomic) IBOutlet UIView *photoView;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *phPhotoTextView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollPhotoView;
@property (strong, nonatomic) IBOutlet UIScrollView *videoView;
@property (strong, nonatomic) IBOutlet UITextField *videoTextField;
@property (strong, nonatomic) IBOutlet UIButton *btnAddVideo;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *phVideoTextViewDescription;
@property (strong, nonatomic) IBOutlet LinkPreview *videoPreviewView;
- (IBAction)cancelBtnClicked:(id)sender;
- (IBAction)shareBtnClicked:(id)sender;
- (IBAction)btnStatusClicked:(id)sender;
- (IBAction)btnPhotosClicked:(id)sender;
- (IBAction)btnVideosClicked:(id)sender;
- (IBAction)btnEventsClicked:(id)sender;
- (IBAction)btnChangeValue:(id)sender;
- (IBAction)btnPermittionClicked:(id)sender;
- (IBAction)btnAddVideoClicked:(id)sender;


- (id) initWithTargetID:(NSInteger) userID;
- (id) initWithUserInfo:(CredentialInfo*) aUserInfo;
@end

@protocol UINewStatusViewControllerDelegate <NSObject>

- (void) didChageView;

@end